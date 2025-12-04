defmodule Aoc2025.Days.Day04 do
  @moduledoc """
  # Day 04: Printing Department

  Optimize forklift operations in a warehouse with paper rolls arranged on a grid.

  ## Part 1

  Count paper rolls (`@`) that are accessible by forklift - those with fewer than
  4 neighboring rolls in the 8 adjacent positions.

  ## Part 2

  Iteratively remove all accessible rolls until none remain. Count total removed.

  ## Approach

  Use a coordinate map for O(1) lookups, then filter rolls by neighbor count.
  """

  use Aoc2025.Day

  @typedoc "A 2D coordinate on the grid"
  @type coord :: {non_neg_integer(), non_neg_integer()}

  @typedoc "Grid mapping coordinates to characters"
  @type warehouse :: %{coord() => String.t()}

  # All 8 directions for neighbor checking (orthogonal + diagonal)
  @directions [{-1, -1}, {0, -1}, {1, -1}, {-1, 0}, {1, 0}, {-1, 1}, {0, 1}, {1, 1}]

  @doc """
  Solve Part 1: Count rolls accessible by forklift (< 4 neighboring rolls).
  """
  @impl true
  @spec part1(String.t()) :: non_neg_integer()
  def part1(input) do
    input
    |> parse()
    |> count_accessible_rolls()
  end

  @doc """
  Solve Part 2: Count total rolls removed through iterative forklift access.
  """
  @impl true
  @spec part2(String.t()) :: non_neg_integer()
  def part2(input) do
    input
    |> parse()
    |> solve_part2()
  end

  @doc """
  Parse the input into a coordinate map.

  ## Input Format

  Grid of `.` (empty) and `@` (paper roll) characters.

  ## Output Format

  Map of `{x, y}` coordinates to single-character strings.
  """
  @impl true
  @spec parse(String.t()) :: warehouse()
  def parse(input), do: grid(input)

  # --- Part 1 Implementation ---

  @spec count_accessible_rolls(warehouse()) :: non_neg_integer()
  defp count_accessible_rolls(warehouse) do
    warehouse
    |> find_rolls()
    |> Enum.count(&accessible?(warehouse, &1))
  end

  @spec find_rolls(warehouse()) :: [coord()]
  defp find_rolls(warehouse) do
    for {coord, "@"} <- warehouse, do: coord
  end

  @spec accessible?(warehouse(), coord()) :: boolean()
  defp accessible?(warehouse, coord) do
    count_roll_neighbors(warehouse, coord) < 4
  end

  @spec count_roll_neighbors(warehouse(), coord()) :: non_neg_integer()
  defp count_roll_neighbors(warehouse, {x, y}) do
    @directions
    |> Enum.count(fn {dx, dy} -> Map.get(warehouse, {x + dx, y + dy}) == "@" end)
  end

  # --- Part 2 Implementation ---

  @spec solve_part2(warehouse()) :: non_neg_integer()
  defp solve_part2(warehouse), do: remove_all_accessible(warehouse, 0)

  @spec remove_all_accessible(warehouse(), non_neg_integer()) :: non_neg_integer()
  defp remove_all_accessible(warehouse, total_removed) do
    accessible = find_accessible_rolls(warehouse)

    case accessible do
      [] ->
        total_removed

      rolls ->
        updated_warehouse = remove_rolls(warehouse, rolls)
        remove_all_accessible(updated_warehouse, total_removed + length(rolls))
    end
  end

  @spec find_accessible_rolls(warehouse()) :: [coord()]
  defp find_accessible_rolls(warehouse) do
    warehouse
    |> find_rolls()
    |> Enum.filter(&accessible?(warehouse, &1))
  end

  @spec remove_rolls(warehouse(), [coord()]) :: warehouse()
  defp remove_rolls(warehouse, coords) do
    Enum.reduce(coords, warehouse, fn coord, acc -> Map.put(acc, coord, ".") end)
  end
end
