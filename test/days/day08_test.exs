defmodule Aoc2025.Days.Day08Test do
  use Aoc2025.DayCase, day: 8

  # Example: After 10 connections, circuits are 5, 4, 2, 2, 1, 1, 1, 1, 1, 1, 1
  # Product of 3 largest = 5 * 4 * 2 = 40
  @example_part1 40
  # Last merge: 216,146,977 and 117,168,530 -> 216 * 117 = 25272
  @example_part2 25_272

  # Puzzle answers - fill in after getting correct answers
  @part1_answer 181_584
  @part2_answer 8_465_902_405

  describe "parsing" do
    test "parses example input correctly" do
      parsed = @day_module.parse(example_input())
      assert length(parsed) == 20
      assert hd(parsed) == {162, 817, 812}
      assert List.last(parsed) == {425, 690, 689}
    end
  end

  describe "part 1" do
    test "example input with 10 connections" do
      # For the example, we need to test with 10 connections, not 1000
      coords = @day_module.parse(example_input())
      result = Aoc2025.Days.Day08.connect_closest_pairs(coords, 10)
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
