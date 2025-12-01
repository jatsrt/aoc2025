defmodule Aoc2025.Days.Day01Test do
  use Aoc2025.DayCase, day: 1

  # Fill in expected answers after solving
  # Example answers come from the puzzle description
  @example_part1 3
  @example_part2 6

  # Puzzle answers - fill in after getting correct answers
  @part1_answer 992
  @part2_answer 6133

  describe "parsing" do
    test "parses example input correctly" do
      parsed = @day_module.parse(example_input())
      assert is_list(parsed)
      assert length(parsed) == 10
      assert hd(parsed) == {:left, 68}
      assert List.last(parsed) == {:left, 82}
    end

    test "parses both L and R instructions" do
      parsed = @day_module.parse("L10\nR20\nL5")
      assert parsed == [{:left, 10}, {:right, 20}, {:left, 5}]
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
