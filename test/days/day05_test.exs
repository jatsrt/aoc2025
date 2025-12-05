defmodule Aoc2025.Days.Day05Test do
  use Aoc2025.DayCase, day: 5

  # Example answers from the puzzle description
  @example_part1 3
  @example_part2 14

  # Puzzle answers - fill in after getting correct answers
  @part1_answer 737
  @part2_answer 357_485_433_193_284

  describe "parsing" do
    test "parses example input correctly" do
      {ranges, ids} = @day_module.parse(example_input())

      assert ranges == [3..5, 10..14, 16..20, 12..18]
      assert ids == [1, 5, 8, 11, 17, 32]
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
