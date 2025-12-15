defmodule Aoc2025.Days.Day12Test do
  use Aoc2025.DayCase, day: 12

  # Example answers from the puzzle description
  @example_part1 2
  @example_part2 nil

  # Puzzle answers - fill in after getting correct answers
  @part1_answer 569
  @part2_answer nil

  describe "parsing" do
    test "parses example input correctly" do
      {shapes, regions} = @day_module.parse(example_input())

      # Should have 6 shapes (indices 0-5)
      assert map_size(shapes) == 6

      # Each shape should have orientations
      assert Enum.all?(shapes, fn {_idx, orients} -> is_list(orients) and length(orients) > 0 end)

      # Should have 3 regions
      assert length(regions) == 3

      # First region is 4x4 with specific counts
      [{w1, h1, c1} | _] = regions
      assert w1 == 4
      assert h1 == 4
      assert c1 == [0, 0, 0, 0, 2, 0]
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
    # Part 2 is a free star for completing AoC 2025 - no puzzle to solve!
  end
end
