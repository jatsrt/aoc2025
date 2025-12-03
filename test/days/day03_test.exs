defmodule Aoc2025.Days.Day03Test do
  use Aoc2025.DayCase, day: 3

  # Example answers come from the puzzle description
  # Part 1: 98 + 89 + 78 + 92 = 357
  # Part 2: 987654321111 + 811111111119 + 434234234278 + 888911112111 = 3121910778619
  @example_part1 357
  @example_part2 3_121_910_778_619

  # Puzzle answers - fill in after getting correct answers
  @part1_answer 17031
  @part2_answer 168_575_096_286_051

  describe "parsing" do
    test "parses example input correctly" do
      parsed = @day_module.parse(example_input())

      assert is_list(parsed)
      assert length(parsed) == 4
      assert hd(parsed) == [9, 8, 7, 6, 5, 4, 3, 2, 1, 1, 1, 1, 1, 1, 1]
    end
  end

  describe "max_joltage/1" do
    test "finds maximum two-digit number for each example bank" do
      # 987654321111111 -> max is 98 (positions 0 and 1)
      assert @day_module.max_joltage([9, 8, 7, 6, 5, 4, 3, 2, 1, 1, 1, 1, 1, 1, 1]) == 98

      # 811111111111119 -> max is 89 (positions 0 and 14)
      assert @day_module.max_joltage([8, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 9]) == 89

      # 234234234234278 -> max is 78 (positions 13 and 14)
      assert @day_module.max_joltage([2, 3, 4, 2, 3, 4, 2, 3, 4, 2, 3, 4, 2, 7, 8]) == 78

      # 818181911112111 -> max is 92 (positions 6 and 11)
      assert @day_module.max_joltage([8, 1, 8, 1, 8, 1, 9, 1, 1, 1, 1, 2, 1, 1, 1]) == 92
    end

    test "handles simple cases" do
      assert @day_module.max_joltage([1, 2]) == 12
      assert @day_module.max_joltage([2, 1]) == 21
      assert @day_module.max_joltage([9, 9]) == 99
      assert @day_module.max_joltage([1, 9, 8]) == 98
    end
  end

  describe "max_joltage_k/2" do
    test "finds maximum 12-digit number for each example bank" do
      # 987654321111111 -> 987654321111
      assert @day_module.max_joltage_k([9, 8, 7, 6, 5, 4, 3, 2, 1, 1, 1, 1, 1, 1, 1], 12) ==
               987_654_321_111

      # 811111111111119 -> 811111111119
      assert @day_module.max_joltage_k([8, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 9], 12) ==
               811_111_111_119

      # 234234234234278 -> 434234234278
      assert @day_module.max_joltage_k([2, 3, 4, 2, 3, 4, 2, 3, 4, 2, 3, 4, 2, 7, 8], 12) ==
               434_234_234_278

      # 818181911112111 -> 888911112111
      assert @day_module.max_joltage_k([8, 1, 8, 1, 8, 1, 9, 1, 1, 1, 1, 2, 1, 1, 1], 12) ==
               888_911_112_111
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
