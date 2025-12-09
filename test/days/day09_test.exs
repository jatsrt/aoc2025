defmodule Aoc2025.Days.Day09Test do
  use Aoc2025.DayCase, day: 9

  # Example: largest rectangle is 50 (between 2,5 and 11,1)
  @example_part1 50
  # Example part 2: largest valid rectangle is 24 (between 9,5 and 2,3)
  @example_part2 24

  # Puzzle answers - fill in after getting correct answers
  @part1_answer 4_735_222_687
  @part2_answer 1_569_262_188

  describe "parsing" do
    test "parses example input correctly" do
      parsed = @day_module.parse(example_input())
      assert length(parsed) == 8
      assert {7, 1} in parsed
      assert {11, 7} in parsed
      assert {2, 5} in parsed
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

  describe "part 2 optimized (sparse table + parallel)" do
    test "example input" do
      result = @day_module.part2_optimized(example_input())
      assert result == @example_part2
    end

    @tag :solution
    test "puzzle input" do
      result = @day_module.part2_optimized(puzzle_input())
      assert result == @part2_answer
    end
  end
end
