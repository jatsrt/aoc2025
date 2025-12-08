defmodule Aoc2025.Days.Day07 do
  @moduledoc """
  # Day 7: Laboratories

  Simulating tachyon beams traveling through a manifold with splitters.

  ## Part 1

  Count how many times a beam is split as it travels through the manifold.
  Beams travel downward from S. When a beam hits a splitter (^), it stops
  and two new beams continue from the left and right of the splitter.

  ## Part 2

  Apply the "many-worlds interpretation" where each split creates distinct
  timelines. Count total timelines (particles don't merge even at same column).

  ## Approach

  Simulate the beams row by row. Track active beam columns as a MapSet.
  When a beam hits a splitter, remove that column and add columns to its
  left and right. Count each splitter hit as a split.
  """

  use Aoc2025.Day

  @typedoc "A column position (0-indexed from left)"
  @type column :: non_neg_integer()

  @typedoc "Parsed manifold with start column and splitter positions by row"
  @type manifold :: %{
          start: column(),
          rows: [[column()]],
          width: non_neg_integer()
        }

  @doc """
  Solve Part 1: Count total beam splits in the manifold.
  """
  @impl true
  @spec part1(String.t()) :: non_neg_integer()
  def part1(input) do
    input
    |> parse()
    |> count_splits()
  end

  @doc """
  Solve Part 2: [To be determined]
  """
  @impl true
  @spec part2(String.t()) :: non_neg_integer()
  def part2(input) do
    input
    |> parse()
    |> solve_part2()
  end

  @doc """
  Parse the input into a manifold structure.

  ## Input Format

  A grid where:
  - `S` marks the starting position of the beam
  - `^` marks splitter positions
  - `.` is empty space

  ## Output Format

  A map containing:
  - `:start` - the column where S is located
  - `:rows` - list of lists, each containing splitter columns for that row
  - `:width` - the width of the grid
  """
  @impl true
  @spec parse(String.t()) :: manifold()
  def parse(input) do
    rows = lines(input)
    width = rows |> hd() |> String.length()

    {start_col, splitter_rows} =
      rows
      |> Enum.reduce({nil, []}, fn row, {start, acc} ->
        splitter_cols = find_chars(row, "^")

        new_start =
          case find_chars(row, "S") do
            [col] -> col
            [] -> start
          end

        {new_start, [splitter_cols | acc]}
      end)

    %{
      start: start_col,
      rows: Enum.reverse(splitter_rows),
      width: width
    }
  end

  defp find_chars(row, char) do
    row
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.filter(fn {c, _} -> c == char end)
    |> Enum.map(fn {_, idx} -> idx end)
  end

  # --- Part 1 Implementation ---

  defp count_splits(%{start: start, rows: rows, width: width}) do
    initial_beams = MapSet.new([start])

    rows
    |> Enum.reduce({initial_beams, 0}, fn splitter_cols, {beams, splits} ->
      process_row(beams, splitter_cols, width, splits)
    end)
    |> elem(1)
  end

  defp process_row(beams, splitter_cols, width, splits) do
    # Find which splitters are hit by beams
    splitters_hit =
      splitter_cols
      |> Enum.filter(&MapSet.member?(beams, &1))

    # Count splits
    new_splits = splits + length(splitters_hit)

    # Update beams: remove hit splitters, add left/right from each hit
    new_beams =
      splitters_hit
      |> Enum.reduce(beams, fn col, acc ->
        acc
        |> MapSet.delete(col)
        |> maybe_add_beam(col - 1, width)
        |> maybe_add_beam(col + 1, width)
      end)

    {new_beams, new_splits}
  end

  defp maybe_add_beam(beams, col, width) when col >= 0 and col < width do
    MapSet.put(beams, col)
  end

  defp maybe_add_beam(beams, _col, _width), do: beams

  # --- Part 2 Implementation ---

  # Count total timelines using many-worlds interpretation.
  # Unlike Part 1, paths don't merge - each distinct path is a separate timeline.
  # We track counts of particles per column instead of just presence.
  defp solve_part2(%{start: start, rows: rows, width: width}) do
    # Map of column -> particle count (instead of MapSet)
    initial_particles = %{start => 1}

    rows
    |> Enum.reduce(initial_particles, fn splitter_cols, particles ->
      process_row_quantum(particles, splitter_cols, width)
    end)
    |> Map.values()
    |> Enum.sum()
  end

  defp process_row_quantum(particles, splitter_cols, width) do
    splitter_set = MapSet.new(splitter_cols)

    particles
    |> Enum.reduce(%{}, fn {col, count}, acc ->
      process_particle(acc, col, count, splitter_set, width)
    end)
  end

  defp process_particle(acc, col, count, splitter_set, width) do
    case MapSet.member?(splitter_set, col) do
      true -> split_particle(acc, col, count, width)
      false -> pass_through_particle(acc, col, count)
    end
  end

  defp split_particle(acc, col, count, width) do
    acc
    |> add_particles(col - 1, count, width)
    |> add_particles(col + 1, count, width)
  end

  defp pass_through_particle(acc, col, count) do
    Map.update(acc, col, count, &(&1 + count))
  end

  defp add_particles(particles, col, count, width) when col >= 0 and col < width do
    Map.update(particles, col, count, &(&1 + count))
  end

  defp add_particles(particles, _col, _count, _width), do: particles
end
