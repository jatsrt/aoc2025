defmodule Aoc2025.Days.Day02Test do
  use Aoc2025.DayCase, day: 2

  # Fill in expected answers after solving
  # Example answers come from the puzzle description
  @example_part1 1_227_775_554
  @example_part2 4_174_379_265

  # Puzzle answers - fill in after getting correct answers
  @part1_answer 38_310_256_125
  @part2_answer 58_961_152_806

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
