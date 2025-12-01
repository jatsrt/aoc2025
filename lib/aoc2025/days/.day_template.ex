# Template for daily solutions - copy and rename to dayXX.ex
# Replace XX with the zero-padded day number (01, 02, etc.)

defmodule Aoc2025.Days.DayXX do
  @moduledoc """
  # Day XX: [Puzzle Title]

  [Brief description of the puzzle]

  ## Part 1

  [Summary of part 1 requirements]

  ## Part 2

  [Summary of part 2 requirements]

  ## Approach

  [High-level description of your solution approach]
  """

  use Aoc2025.Day

  # Types - define custom types for your solution
  # @typedoc "Description of your type"
  # @type my_type :: ...

  @doc """
  Solve Part 1: [brief description]
  """
  @impl true
  @spec part1(String.t()) :: non_neg_integer()
  def part1(input) do
    input
    |> parse()
    |> solve_part1()
  end

  @doc """
  Solve Part 2: [brief description]
  """
  @impl true
  @spec part2(String.t()) :: non_neg_integer()
  def part2(input) do
    input
    |> parse()
    |> solve_part2()
  end

  @doc """
  Parse the input into a usable data structure.

  ## Input Format

  [Describe the input format]

  ## Output Format

  [Describe what the parse function returns]
  """
  @spec parse(String.t()) :: term()
  def parse(input) do
    # TODO: Implement parsing
    input
    |> lines()
  end

  # --- Part 1 Implementation ---

  defp solve_part1(data) do
    # TODO: Implement part 1 solution
    data
  end

  # --- Part 2 Implementation ---

  defp solve_part2(data) do
    # TODO: Implement part 2 solution
    data
  end
end
