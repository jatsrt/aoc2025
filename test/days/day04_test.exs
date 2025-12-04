defmodule Aoc2025.Days.Day04Test do
  use Aoc2025.DayCase, day: 4

  # Fill in expected answers after solving
  # Example answers come from the puzzle description
  @example_part1 13
  @example_part2 43

  # Puzzle answers - fill in after getting correct answers
  @part1_answer 1602
  @part2_answer 9518

  describe "parsing" do
    test "parses example input correctly" do
      parsed = @day_module.parse(example_input())
      # Parse returns a coordinate map
      assert is_map(parsed)
      # Check a few known positions from example
      assert parsed[{0, 0}] == "."
      assert parsed[{2, 0}] == "@"
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
