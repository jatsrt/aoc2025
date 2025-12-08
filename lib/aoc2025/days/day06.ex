defmodule Aoc2025.Days.Day06 do
  @moduledoc """
  # Day 6: Trash Compactor

  Parse a math worksheet where problems are arranged in columns, with numbers
  stacked vertically and operators at the bottom.

  ## Part 1

  Parse the column-based worksheet row-by-row. Numbers span multiple columns
  and are read horizontally within each problem group.

  ## Part 2

  Parse using "cephalopod math" - each column is a single number with digits
  read top-to-bottom (MSD first), and columns are processed right-to-left.

  ## Approach

  Both parts share the same column-grouping strategy:
  1. Pad rows to equal length, split into graphemes
  2. Transpose rows→columns
  3. Group columns by all-space separators

  Part 1: Transpose each group back to rows, read numbers horizontally
  Part 2: Read each column vertically as one number, reverse for RTL order
  """

  use Aoc2025.Day

  @typedoc "A single problem: operator and list of numbers"
  @type problem :: {:add | :multiply, [non_neg_integer()]}

  @doc """
  Solve Part 1: Sum of all problem results on the worksheet.
  """
  @impl true
  @spec part1(String.t()) :: non_neg_integer()
  def part1(input) do
    input
    |> parse()
    |> Enum.map(&solve_problem/1)
    |> Enum.sum()
  end

  @doc """
  Solve Part 2: Cephalopod math - read columns right-to-left, digits top-to-bottom.
  """
  @impl true
  @spec part2(String.t()) :: non_neg_integer()
  def part2(input) do
    input
    |> parse_cephalopod()
    |> Enum.map(&solve_problem/1)
    |> Enum.sum()
  end

  @doc """
  Parse the column-based worksheet into a list of problems.

  ## Input Format

  Numbers arranged in columns with operators at the bottom.
  Problems are separated by columns of only spaces.

  ## Output Format

  List of `{operator, [numbers]}` tuples.
  """
  @impl true
  @spec parse(String.t()) :: [problem()]
  def parse(input) do
    rows = input |> String.split("\n", trim: true)

    # Convert to list of charlists for column access
    # Pad all rows to same length
    max_len = rows |> Enum.map(&String.length/1) |> Enum.max()

    padded_rows =
      rows
      |> Enum.map(fn row -> String.pad_trailing(row, max_len) end)
      |> Enum.map(&String.graphemes/1)

    # Transpose to get columns
    columns = transpose(padded_rows)

    # Group columns by finding separators (all-space columns)
    columns
    |> group_by_separator()
    |> Enum.map(&parse_problem_group/1)
  end

  defp transpose([[] | _]), do: []

  defp transpose(rows) do
    [Enum.map(rows, &hd/1) | transpose(Enum.map(rows, &tl/1))]
  end

  defp group_by_separator(columns) do
    columns
    |> Enum.chunk_by(&all_spaces?/1)
    |> Enum.reject(&all_spaces?(hd(&1)))
  end

  defp all_spaces?(column), do: Enum.all?(column, &(&1 == " "))

  defp parse_problem_group(columns) do
    # Each column group represents one problem
    # The bottom row contains the operator, rest are number digits
    # We need to read each row horizontally within this group

    rows = transpose(columns)

    # Last row has the operator
    operator_row = List.last(rows)
    number_rows = Enum.drop(rows, -1)

    operator = parse_operator(operator_row)

    numbers =
      number_rows
      |> Enum.map(&parse_number_row/1)
      |> Enum.reject(&is_nil/1)

    {operator, numbers}
  end

  defp parse_operator(row) do
    chars = Enum.join(row) |> String.trim()

    case chars do
      "+" -> :add
      "*" -> :multiply
    end
  end

  defp parse_number_row(row) do
    str = Enum.join(row) |> String.trim()

    if str == "" do
      nil
    else
      String.to_integer(str)
    end
  end

  defp solve_problem({:add, numbers}), do: Enum.sum(numbers)
  defp solve_problem({:multiply, numbers}), do: Enum.product(numbers)

  # --- Part 2 Implementation ---

  @doc """
  Parse using cephalopod math: each column is one number (digits top-to-bottom),
  columns read right-to-left within each problem group.
  """
  @spec parse_cephalopod(String.t()) :: [problem()]
  def parse_cephalopod(input) do
    rows = input |> String.split("\n", trim: true)
    max_len = rows |> Enum.map(&String.length/1) |> Enum.max()

    padded_rows =
      rows
      |> Enum.map(&String.pad_trailing(&1, max_len))
      |> Enum.map(&String.graphemes/1)

    columns = transpose(padded_rows)

    columns
    |> group_by_separator()
    |> Enum.map(&parse_cephalopod_group/1)
  end

  defp parse_cephalopod_group(columns) do
    # Each column in the group is one number (reading digits top-to-bottom)
    # The last element in each column is the operator character
    # Read columns right-to-left

    operator =
      columns
      |> Enum.map(&List.last/1)
      |> Enum.find(&(&1 in ["*", "+"]))
      |> case do
        "+" -> :add
        "*" -> :multiply
      end

    # For each column, take all but last row (operator row), filter spaces, join as number
    numbers =
      columns
      |> Enum.map(fn col ->
        col
        |> Enum.drop(-1)
        |> Enum.reject(&(&1 == " "))
        |> Enum.join()
      end)
      |> Enum.reject(&(&1 == ""))
      |> Enum.map(&String.to_integer/1)
      |> Enum.reverse()

    {operator, numbers}
  end
end
