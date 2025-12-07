defmodule Aoc2025.Days.Day07Test do
  use Aoc2025.DayCase, day: 7

  # Example answers from puzzle description
  @example_part1 21
  @example_part2 40

  # Puzzle answers - fill in after getting correct answers
  @part1_answer 1581
  @part2_answer 73_007_003_089_792

  describe "parsing" do
    test "parses example input correctly" do
      parsed = @day_module.parse(example_input())

      # S is at column 7
      assert parsed.start == 7

      # Grid is 15 wide
      assert parsed.width == 15

      # First row has S, no splitters
      assert Enum.at(parsed.rows, 0) == []

      # Row 2 has a splitter at column 7
      assert Enum.at(parsed.rows, 2) == [7]

      # Row 4 has splitters at columns 6 and 8
      assert Enum.at(parsed.rows, 4) == [6, 8]
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
