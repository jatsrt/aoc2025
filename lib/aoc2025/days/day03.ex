defmodule Aoc2025.Days.Day03 do
  @moduledoc """
  # Day 03: Lobby Puzzle

  Batteries in a lobby need to power an escalator. Each battery bank (line) has
  single-digit joltage ratings. We select batteries and form a number from their
  digits in order.

  ## Part 1

  Select exactly 2 batteries per bank. Find the maximum joltage each bank can
  produce and sum them all.

  ## Part 2

  Select exactly 12 batteries per bank. Same goal - maximize joltage per bank
  and sum them all.

  ## Approach

  **Part 1:** Use suffix maximums for O(n) efficiency.

  **Part 2:** Greedy selection - for each of the k positions, pick the largest
  digit that still leaves enough digits for remaining positions. For position j,
  we can pick from indices [prev+1, n-k+j].
  """

  use Aoc2025.Day

  @typedoc "A battery bank represented as a list of single-digit joltage values"
  @type bank :: [1..9]

  @doc """
  Solve Part 1: Find the sum of maximum joltages across all banks.
  """
  @impl true
  @spec part1(String.t()) :: non_neg_integer()
  def part1(input), do: input |> parse() |> solve_part1()

  @doc """
  Solve Part 2: Find the sum of maximum 12-digit joltages across all banks.
  """
  @impl true
  @spec part2(String.t()) :: non_neg_integer()
  def part2(input), do: input |> parse() |> solve_part2()

  @doc """
  Parse the input into a list of battery banks.

  ## Input Format

  Each line contains a sequence of digits (1-9) representing battery joltage values.

  ## Output Format

  Returns a list of banks, where each bank is a list of integers (1-9).
  """
  @impl true
  @spec parse(String.t()) :: [bank()]
  def parse(input) do
    input
    |> lines()
    |> Enum.map(&parse_bank/1)
  end

  @spec parse_bank(String.t()) :: bank()
  defp parse_bank(line) do
    line
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end

  # --- Part 1 Implementation ---
  # Uses the general k-digit solution for consistency and simplicity.
  # See max_joltage/1 for an optimized O(n) alternative when k=2.

  @spec solve_part1([bank()]) :: non_neg_integer()
  defp solve_part1(banks), do: banks |> Enum.map(&max_joltage_k(&1, 2)) |> Enum.sum()

  @doc """
  Find the maximum two-digit joltage for a single bank.

  This is an **optimized O(n) alternative** to `max_joltage_k(digits, 2)`.
  While the general greedy algorithm is O(n*k), this specialized version
  uses suffix maximums to achieve O(n) time complexity for the k=2 case.

  ## Algorithm

  Uses suffix maximums for O(n) efficiency:
  - `suffix_max[i]` = maximum digit at any position > i
  - Best pair at position i = `digits[i] * 10 + suffix_max[i]`

  ## When to Use

  For educational purposes, the main solution uses `max_joltage_k/2` for
  consistency. This function demonstrates how domain-specific optimizations
  can improve performance when the problem structure allows it.
  """
  @spec max_joltage(bank()) :: non_neg_integer()
  def max_joltage(digits) do
    suffix_maxes = compute_suffix_maxes(digits)

    digits
    |> Enum.zip(suffix_maxes)
    |> Enum.filter(fn {_d, max_after} -> max_after > 0 end)
    |> Enum.map(fn {d, max_after} -> d * 10 + max_after end)
    |> Enum.max()
  end

  @spec compute_suffix_maxes(bank()) :: [non_neg_integer()]
  defp compute_suffix_maxes(digits) do
    # Build suffix max array by scanning from the end
    # suffix_max[i] = max digit at positions > i
    {suffix_maxes, _} =
      digits
      |> Enum.reverse()
      |> Enum.map_reduce(0, fn d, max_after ->
        {max_after, max(d, max_after)}
      end)

    Enum.reverse(suffix_maxes)
  end

  # --- Part 2 Implementation ---

  @spec solve_part2([bank()]) :: non_neg_integer()
  defp solve_part2(banks), do: banks |> Enum.map(&max_joltage_k(&1, 12)) |> Enum.sum()

  @doc """
  Find the maximum k-digit joltage for a single bank using greedy selection.

  For each of the k positions, we pick the largest digit that still leaves
  enough digits for the remaining positions.

  For position j (0-indexed), having just picked at index prev:
  - We can pick from indices [prev+1, n-k+j]
  - This ensures we have (k-j-1) indices remaining for the rest
  """
  @spec max_joltage_k(bank(), pos_integer()) :: non_neg_integer()
  def max_joltage_k(digits, k) do
    digits_tuple = List.to_tuple(digits)
    n = tuple_size(digits_tuple)

    select_k_digits(digits_tuple, n, k, 0, 0, [])
    |> Enum.reverse()
    |> Integer.undigits()
  end

  @spec select_k_digits(
          tuple(),
          non_neg_integer(),
          pos_integer(),
          non_neg_integer(),
          non_neg_integer(),
          [1..9]
        ) ::
          [1..9]
  defp select_k_digits(_digits, _n, k, k, _prev, acc), do: acc

  defp select_k_digits(digits, n, k, j, prev, acc) do
    # For position j, can pick from prev to (n - k + j) inclusive
    end_idx = n - k + j

    # Find the maximum digit and its index in the valid range
    {max_digit, max_idx} = find_max_in_range(digits, prev, end_idx)

    select_k_digits(digits, n, k, j + 1, max_idx + 1, [max_digit | acc])
  end

  @spec find_max_in_range(tuple(), non_neg_integer(), non_neg_integer()) ::
          {1..9, non_neg_integer()}
  defp find_max_in_range(digits, start_idx, end_idx) do
    start_idx..end_idx
    |> Enum.map(fn i -> {elem(digits, i), i} end)
    |> Enum.max_by(fn {d, _i} -> d end)
  end
end
