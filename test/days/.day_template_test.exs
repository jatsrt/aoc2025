# Template for daily tests - copy and rename to dayXX_test.exs
# Replace XX with the zero-padded day number (01, 02, etc.)

defmodule Aoc2025.Days.DayXXTest do
  # <- Change to actual day number
  use Aoc2025.DayCase, day: 0

  # Fill in expected answers after solving
  # Example answers come from the puzzle description
  @example_part1 nil
  @example_part2 nil

  # Puzzle answers - fill in after getting correct answers
  @part1_answer nil
  @part2_answer nil

  describe "parsing" do
    test "parses example input correctly" do
      parsed = @day_module.parse(example_input())
      # Add assertions about parsed structure
      assert is_list(parsed)
    end
  end

  describe "part 1" do
    test "example input" do
      result = @day_module.part1(example_input())
      assert result == @example_part1
    end

    @tag :solution
    test "puzzle input" do
      result = @day_module.part1(puzzle_input())
      assert result == @part1_answer
    end
  end

  describe "part 2" do
    test "example input" do
      result = @day_module.part2(example_input())
      assert result == @example_part2
    end

    @tag :solution
    test "puzzle input" do
      result = @day_module.part2(puzzle_input())
      assert result == @part2_answer
    end
  end
end
