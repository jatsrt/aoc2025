defmodule Aoc2025.Days.Day11 do
  @moduledoc """
  # Day 11: Reactor

  A directed graph path counting problem. Devices form a network where data flows
  from one device to its outputs. We need to count all possible paths between
  devices.

  ## Part 1

  Count all distinct paths from "you" to "out" in the device graph.

  ## Part 2

  Count paths from "svr" to "out" that pass through both "dac" and "fft" (in any
  order).

  ## Approach

  This is a classic DAG (Directed Acyclic Graph) path counting problem. We use
  memoized recursion:
  - Base case: paths to target = 1
  - Recursive case: paths from a node = sum of paths from all its neighbors

  For Part 2, we decompose into segments:
  - Paths via dac→fft: count(svr→dac) × count(dac→fft) × count(fft→out)
  - Paths via fft→dac: count(svr→fft) × count(fft→dac) × count(dac→out)

  The memoization is critical for performance since the same intermediate nodes
  may be reached via many different paths.
  """

  use Aoc2025.Day

  @typedoc "Device name as a string"
  @type device :: String.t()

  @typedoc "Graph represented as map from device to list of output devices"
  @type graph :: %{device() => [device()]}

  @doc """
  Solve Part 1: Count all paths from "you" to "out".
  """
  @impl true
  @spec part1(String.t()) :: non_neg_integer()
  def part1(input), do: input |> parse() |> count_paths("you", "out")

  @doc """
  Solve Part 2: Count paths from "svr" to "out" passing through both "dac" and "fft".
  """
  @impl true
  @spec part2(String.t()) :: non_neg_integer()
  def part2(input) do
    input
    |> parse()
    |> count_paths_through_both("svr", "out", "dac", "fft")
  end

  @doc """
  Parse the input into a directed graph.

  ## Input Format

  Each line has format: `device: output1 output2 ...`
  where device is connected to each listed output.

  ## Output Format

  A map where keys are device names and values are lists of output devices.
  """
  @impl true
  @spec parse(String.t()) :: graph()
  def parse(input) do
    input
    |> lines()
    |> Map.new(&parse_line/1)
  end

  defp parse_line(line) do
    [device, outputs] = String.split(line, ": ")
    {device, String.split(outputs, " ")}
  end

  # --- Part 1 Implementation ---

  @doc """
  Count all paths from `start` to `target` in the graph using memoization.
  """
  @spec count_paths(graph(), device(), device()) :: non_neg_integer()
  def count_paths(graph, start, target) do
    {count, _memo} = count_paths_memo(graph, start, target, %{})
    count
  end

  defp count_paths_memo(_graph, target, target, memo), do: {1, memo}

  defp count_paths_memo(graph, node, target, memo) do
    case Map.fetch(memo, node) do
      {:ok, count} ->
        {count, memo}

      :error ->
        neighbors = Map.get(graph, node, [])

        {count, updated_memo} =
          Enum.reduce(neighbors, {0, memo}, fn neighbor, {acc, current_memo} ->
            {neighbor_count, new_memo} = count_paths_memo(graph, neighbor, target, current_memo)
            {acc + neighbor_count, new_memo}
          end)

        {count, Map.put(updated_memo, node, count)}
    end
  end

  # --- Part 2 Implementation ---

  @doc """
  Count paths from `start` to `target` that pass through both `via1` and `via2`.

  Since order can vary, we compute:
  - Paths going start → via1 → via2 → target
  - Plus paths going start → via2 → via1 → target
  """
  @spec count_paths_through_both(graph(), device(), device(), device(), device()) ::
          non_neg_integer()
  def count_paths_through_both(graph, start, target, via1, via2) do
    # Path: start → via1 → via2 → target
    via1_first =
      count_paths(graph, start, via1) *
        count_paths(graph, via1, via2) *
        count_paths(graph, via2, target)

    # Path: start → via2 → via1 → target
    via2_first =
      count_paths(graph, start, via2) *
        count_paths(graph, via2, via1) *
        count_paths(graph, via1, target)

    via1_first + via2_first
  end
end
