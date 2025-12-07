defmodule Aoc2025.Days.Day06Test do
  use Aoc2025.DayCase, day: 6

  # Example: 33210 + 490 + 4243455 + 401 = 4277556
  @example_part1 4_277_556
  # Example Part 2: 1058 + 3253600 + 625 + 8544 = 3263827
  @example_part2 3_263_827

  # Puzzle answers - fill in after getting correct answers
  @part1_answer 3_785_892_992_137
  @part2_answer 7_669_802_156_452

  describe "parsing" do
    test "parses example input correctly" do
      parsed = @day_module.parse(example_input())

      # Should have 4 problems
      assert length(parsed) == 4

      # Verify each problem
      assert Enum.at(parsed, 0) == {:multiply, [123, 45, 6]}
      assert Enum.at(parsed, 1) == {:add, [328, 64, 98]}
      assert Enum.at(parsed, 2) == {:multiply, [51, 387, 215]}
      assert Enum.at(parsed, 3) == {:add, [64, 23, 314]}
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
