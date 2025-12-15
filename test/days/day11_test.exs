defmodule Aoc2025.Days.Day11Test do
  use Aoc2025.DayCase, day: 11

  # Example answer from puzzle description
  @example_part1 5
  @example_part2 2

  # Puzzle answers - fill in after getting correct answers
  @part1_answer 699
  @part2_answer 388_893_655_378_800

  describe "parsing" do
    test "parses example input correctly" do
      parsed = @day_module.parse(example_input())

      assert parsed["you"] == ["bbb", "ccc"]
      assert parsed["bbb"] == ["ddd", "eee"]
      assert parsed["ccc"] == ["ddd", "eee", "fff"]
      assert parsed["ddd"] == ["ggg"]
      assert parsed["eee"] == ["out"]
      assert parsed["fff"] == ["out"]
      assert parsed["ggg"] == ["out"]
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
      # Part 2 uses a different example
      example_part2_input = File.read!("priv/inputs/examples/day11_part2.txt")
      result = @day_module.part2(example_part2_input)
      assert result == @example_part2
    end

    @tag :solution
    test "puzzle input" do
      result = @day_module.part2(puzzle_input())
      assert result == @part2_answer
    end
  end
end
