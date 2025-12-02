defmodule Aoc2025.Days.Day02 do
  @moduledoc """
  # Day 2: Gift Shop

  Find invalid product IDs in ranges. An invalid ID is any number made of
  a digit sequence repeated twice (e.g., 55, 6464, 123123).

  ## Part 1

  Sum all invalid IDs found within the given ranges.

  ## Part 2

  Same as Part 1, but invalid IDs are patterns repeated **at least twice**
  (not exactly twice). Uses MapSet for deduplication.

  ## Approach

  Rather than checking every number in each range (which could be millions),
  we mathematically generate all possible "doubled" numbers and check if they
  fall within each range.

  A doubled number with base `n` (k digits) equals `n × (10^k + 1)`.
  For example: 64 × 101 = 6464.
  """

  use Aoc2025.Day

  @typedoc "A range of product IDs {start, end} inclusive"
  @type id_range :: {pos_integer(), pos_integer()}

  @doc "Solve Part 1: Sum all invalid (doubled) IDs in the given ranges."
  @impl true
  @spec part1(String.t()) :: non_neg_integer()
  def part1(input), do: input |> parse() |> Enum.flat_map(&find_invalid_ids/1) |> Enum.sum()

  @doc "Solve Part 2: Sum all IDs with patterns repeated at least twice."
  @impl true
  @spec part2(String.t()) :: non_neg_integer()
  def part2(input), do: input |> parse() |> solve_part2()

  @doc """
  Parse the input into a list of ID ranges.

  ## Input Format

  Single line of comma-separated ranges: "11-22,95-115,..."

  ## Output Format

  List of {start, end} tuples representing inclusive ranges.
  """
  @impl true
  @spec parse(String.t()) :: [id_range()]
  def parse(input) do
    input |> String.trim() |> String.split(",", trim: true) |> Enum.map(&parse_range/1)
  end

  @spec parse_range(String.t()) :: id_range()
  defp parse_range(range_str) do
    [start, stop] = range_str |> String.split("-") |> Enum.map(&String.to_integer/1)
    {start, stop}
  end

  # --- Part 1 Implementation ---

  @doc """
  Find all invalid (doubled) IDs within a range.

  Uses mathematical generation rather than iteration:
  A doubled number with k-digit base `n` equals `n × (10^k + 1)`.
  """
  @spec find_invalid_ids(id_range()) :: [pos_integer()]
  def find_invalid_ids({start, stop}) do
    max_k = div(num_digits(stop), 2) + 1

    for k <- 1..max_k,
        doubled <- find_pattern_ids(k, Integer.pow(10, k) + 1, start, stop),
        do: doubled
  end

  # --- Part 2 Implementation ---

  @doc """
  Find all invalid IDs where a pattern repeats at least twice.

  A k-digit pattern repeated m times (m >= 2) equals:
  pattern × repunit(k, m), where repunit = (10^(k×m) - 1) / (10^k - 1)
  """
  @spec find_invalid_ids_v2(id_range()) :: [pos_integer()]
  def find_invalid_ids_v2({start, stop}) do
    max_digits = num_digits(stop)

    for k <- 1..div(max_digits, 2),
        m <- 2..div(max_digits, k),
        invalid_id <- find_pattern_ids(k, repunit(k, m), start, stop),
        do: invalid_id
  end

  @spec solve_part2([id_range()]) :: non_neg_integer()
  defp solve_part2(ranges) do
    ranges |> Enum.flat_map(&find_invalid_ids_v2/1) |> MapSet.new() |> Enum.sum()
  end

  # --- Shared Pattern Finding Logic ---

  @doc """
  Find all pattern-based IDs within a range for a given multiplier.

  Given a k-digit base pattern and a multiplier, finds all valid patterns
  where `pattern × multiplier` falls within [start, stop].
  """
  @spec find_pattern_ids(pos_integer(), pos_integer(), pos_integer(), pos_integer()) ::
          [pos_integer()]
  def find_pattern_ids(k, multiplier, start, stop) do
    {min_base, max_base} = base_range(k)
    actual_min = max(min_base, ceiling_div(start, multiplier))
    actual_max = min(max_base, div(stop, multiplier))

    generate_ids(actual_min, actual_max, multiplier)
  end

  # Multi-clause function replaces if/else - empty list when no valid range
  @spec generate_ids(pos_integer(), pos_integer(), pos_integer()) :: [pos_integer()]
  defp generate_ids(min, max, _multiplier) when min > max, do: []
  defp generate_ids(min, max, multiplier), do: Enum.map(min..max, &(&1 * multiplier))

  # Valid base range for k digits: [10^(k-1), 10^k - 1], except k=1 is [1, 9]
  @spec base_range(pos_integer()) :: {pos_integer(), pos_integer()}
  defp base_range(1), do: {1, 9}
  defp base_range(k), do: {Integer.pow(10, k - 1), Integer.pow(10, k) - 1}

  # Repunit for k-digit pattern repeated m times: (10^(k×m) - 1) / (10^k - 1)
  @spec repunit(pos_integer(), pos_integer()) :: pos_integer()
  defp repunit(k, m), do: div(Integer.pow(10, k * m) - 1, Integer.pow(10, k) - 1)

  @spec ceiling_div(pos_integer(), pos_integer()) :: pos_integer()
  defp ceiling_div(a, b), do: div(a + b - 1, b)

  @spec num_digits(pos_integer()) :: pos_integer()
  defp num_digits(n), do: n |> Integer.to_string() |> String.length()
end
