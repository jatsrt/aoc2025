defmodule Aoc2025.DayCase do
  @moduledoc """
  Test case template for daily solutions.

  Use this module in your day tests to get consistent test structure
  and helpful assertions.

  ## Example

      defmodule Aoc2025.Days.Day01Test do
        use Aoc2025.DayCase, day: 1

        # Expected answers (fill in after solving)
        @example_part1 142
        @example_part2 281

        @part1_answer 54601
        @part2_answer 54078

        describe "part 1" do
          test "example input" do
            assert @day_module.part1(example_input()) == @example_part1
          end

          @tag :solution
          test "puzzle input" do
            assert @day_module.part1(puzzle_input()) == @part1_answer
          end
        end

        describe "part 2" do
          test "example input" do
            assert @day_module.part2(example_input()) == @example_part2
          end

          @tag :solution
          test "puzzle input" do
            assert @day_module.part2(puzzle_input()) == @part2_answer
          end
        end
      end
  """

  defmacro __using__(opts) do
    day = Keyword.fetch!(opts, :day)
    day_str = day |> Integer.to_string() |> String.pad_leading(2, "0")
    module_name = Module.concat([Aoc2025, Days, "Day#{day_str}"])

    quote do
      use ExUnit.Case, async: true

      @day unquote(day)
      @day_module unquote(module_name)

      @doc "Load the example input for this day"
      def example_input do
        Aoc2025.Input.load_example(@day)
      end

      @doc "Load the full puzzle input for this day"
      def puzzle_input do
        Aoc2025.Input.load(@day)
      end
    end
  end
end
