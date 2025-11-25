defmodule Aoc2025 do
  @moduledoc """
  # Advent of Code 2025 - Elixir Solutions

  This project contains solutions to the [Advent of Code 2025](https://adventofcode.com/2025)
  programming challenges, implemented in Elixir with a focus on:

  - **Educational value**: Each solution is thoroughly documented with explanations
  - **Clean code**: Idiomatic Elixir with clear patterns
  - **Test coverage**: Example inputs verified before attempting full solutions

  ## Quick Start

      # Run a specific day's solution
      mix day 1

      # Run with example input
      mix example 1

      # Run tests for a specific day
      mix test.day 1

      # Run all tests
      mix test

  ## Project Structure

      lib/
        aoc2025/
          days/        # Daily solutions (day01.ex, day02.ex, ...)
          day.ex       # Behaviour and helpers for solutions
          input.ex     # Input loading utilities
      priv/
        inputs/        # Full puzzle inputs (day01.txt, ...)
          examples/    # Example inputs from problems
      solutions/       # Solution writeups (day01.md, ...)
      test/
        days/          # Tests for each day

  ## Adding a New Day

  1. Create the solution module in `lib/aoc2025/days/dayXX.ex`
  2. Add input files to `priv/inputs/`
  3. Create tests in `test/days/dayXX_test.exs`
  4. Document the solution in `solutions/dayXX.md`
  """

  @doc """
  Run all completed days and return their results.
  """
  def run_all do
    1..25
    |> Enum.filter(&day_exists?/1)
    |> Enum.map(fn day ->
      module = day_module(day)
      IO.puts("\n#{"=" |> String.duplicate(50)}")
      IO.puts("Day #{day}")
      IO.puts("=" |> String.duplicate(50))
      {day, module.run()}
    end)
  end

  @doc """
  List all implemented days.
  """
  def implemented_days do
    1..25
    |> Enum.filter(&day_exists?/1)
  end

  defp day_exists?(day) do
    module = day_module(day)
    Code.ensure_loaded?(module)
  end

  defp day_module(day) do
    day_str = day |> Integer.to_string() |> String.pad_leading(2, "0")
    Module.concat([Aoc2025, Days, "Day#{day_str}"])
  end
end
