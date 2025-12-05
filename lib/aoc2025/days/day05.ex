defmodule Aoc2025.Days.Day05 do
  @moduledoc """
  # Day 05: Cafeteria

  An inventory management system for categorizing ingredient IDs as fresh or spoiled.

  ## Part 1

  Given inclusive ranges of fresh ingredient IDs and a list of available IDs,
  count how many available IDs fall within any fresh range.

  ## Part 2

  Count the total number of unique ingredient IDs that would be considered fresh
  across all ranges (handling overlaps).

  ## Approach

  - **Part 1**: For each available ID, check membership in any range using `Enum.any?/2`
  - **Part 2**: Merge overlapping ranges, then sum their sizes mathematically
    (can't enumerate IDs since ranges span up to 10^14 values)
  """

  use Aoc2025.Day

  # Types
  @typedoc "An inclusive range of fresh ingredient IDs"
  @type fresh_range :: Range.t()

  @typedoc "An ingredient ID"
  @type ingredient_id :: non_neg_integer()

  @typedoc "Parsed input: fresh ranges and available ingredient IDs"
  @type inventory :: {[fresh_range()], [ingredient_id()]}

  @doc """
  Solve Part 1: Count how many available IDs are fresh.
  """
  @impl true
  @spec part1(String.t()) :: non_neg_integer()
  def part1(input) do
    input
    |> parse()
    |> solve_part1()
  end

  @doc """
  Solve Part 2: Count total unique fresh ingredient IDs across all ranges.
  """
  @impl true
  @spec part2(String.t()) :: non_neg_integer()
  def part2(input) do
    input
    |> parse()
    |> solve_part2()
  end

  @doc """
  Parse the input into fresh ranges and available ingredient IDs.

  ## Input Format

  The input has two sections separated by a blank line:
  1. Fresh ID ranges in format "start-end"
  2. Available ingredient IDs, one per line

  ## Output Format

  A tuple of {ranges, ids} where:
  - ranges: list of Elixir Range structs (inclusive)
  - ids: list of ingredient ID integers
  """
  @impl true
  @spec parse(String.t()) :: inventory()
  def parse(input) do
    [ranges_section, ids_section] = paragraphs(input)

    ranges =
      ranges_section
      |> lines()
      |> Enum.flat_map(&extract_ranges/1)

    ids =
      ids_section
      |> lines()
      |> Enum.map(&String.to_integer/1)

    {ranges, ids}
  end

  # --- Part 1 Implementation ---

  @spec solve_part1(inventory()) :: non_neg_integer()
  defp solve_part1({ranges, ids}) do
    ids
    |> Enum.count(&fresh?(&1, ranges))
  end

  @spec fresh?(ingredient_id(), [fresh_range()]) :: boolean()
  defp fresh?(id, ranges) do
    Enum.any?(ranges, fn range -> id in range end)
  end

  # --- Part 2 Implementation ---

  @spec solve_part2(inventory()) :: non_neg_integer()
  defp solve_part2({ranges, _ids}) do
    ranges
    |> merge_ranges()
    |> Enum.map(&range_size/1)
    |> Enum.sum()
  end

  @spec merge_ranges([fresh_range()]) :: [fresh_range()]
  defp merge_ranges(ranges) do
    ranges
    |> Enum.sort_by(fn first.._//_ -> first end)
    |> Enum.reduce([], &merge_into/2)
    |> Enum.reverse()
  end

  @spec merge_into(fresh_range(), [fresh_range()]) :: [fresh_range()]
  defp merge_into(range, []), do: [range]

  defp merge_into(new_start..new_end//_, [current_start..current_end//_ | rest])
       when new_start <= current_end + 1 do
    # Ranges overlap or are adjacent - merge them
    [current_start..max(current_end, new_end) | rest]
  end

  defp merge_into(range, acc), do: [range | acc]

  @spec range_size(fresh_range()) :: non_neg_integer()
  defp range_size(first..last//_), do: last - first + 1
end
