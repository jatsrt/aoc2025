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

      assert is_list(parsed)
      assert length(parsed) == 11
      # First range is 11-22
      assert hd(parsed) == {11, 22}
      # Last range is 2121212118-2121212124
      assert List.last(parsed) == {2_121_212_118, 2_121_212_124}
    end

    test "parses single range" do
      assert @day_module.parse("11-22") == [{11, 22}]
    end

    test "parses multiple comma-separated ranges" do
      parsed = @day_module.parse("11-22,95-115,998-1012")

      assert parsed == [{11, 22}, {95, 115}, {998, 1012}]
    end

    test "handles large numbers correctly" do
      parsed = @day_module.parse("1188511880-1188511890")

      assert parsed == [{1_188_511_880, 1_188_511_890}]
    end

    test "handles whitespace in input" do
      parsed = @day_module.parse("  11-22,95-115  \n")

      assert parsed == [{11, 22}, {95, 115}]
    end
  end

  describe "find_invalid_ids/1" do
    test "finds single-digit doubled numbers" do
      # Range 11-22 contains doubled: 11, 22
      assert @day_module.find_invalid_ids({11, 22}) == [11, 22]
    end

    test "finds multi-digit doubled numbers" do
      # Range 6460-6470 contains 6464 (64 doubled)
      assert @day_module.find_invalid_ids({6460, 6470}) == [6464]
    end

    test "finds three-digit base doubled numbers" do
      # 123123 = 123 × 1001
      assert @day_module.find_invalid_ids({123_120, 123_130}) == [123_123]
    end

    test "returns empty list when no doubled numbers in range" do
      assert @day_module.find_invalid_ids({12, 20}) == []
    end

    test "finds multiple doubled numbers of different digit lengths" do
      # Range 95-115 contains: 99 (9×11), 1010 is outside, 1111 is outside
      # Actually just 99 in this range
      invalid = @day_module.find_invalid_ids({95, 115})
      assert 99 in invalid
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
