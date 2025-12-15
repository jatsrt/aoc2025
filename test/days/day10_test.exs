defmodule Aoc2025.Days.Day10Test do
  use Aoc2025.DayCase, day: 10

  # Example answers from the puzzle description
  @example_part1 7
  @example_part2 33

  # Puzzle answers - fill in after getting correct answers
  @part1_answer 401
  @part2_answer 15017

  describe "parsing" do
    test "parses example input correctly" do
      parsed = @day_module.parse(example_input())

      assert length(parsed) == 3

      # First machine: [.##.] with 6 buttons and joltage {3,5,4,7}
      {target1, buttons1, joltage1} = hd(parsed)
      assert target1 == [false, true, true, false]
      assert length(buttons1) == 6
      assert hd(buttons1) == [3]
      assert Enum.at(buttons1, 1) == [1, 3]
      assert joltage1 == [3, 5, 4, 7]
    end

    test "parses single machine" do
      line = "[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}"
      {target, buttons, joltage} = @day_module.parse_machine(line)

      assert target == [false, true, true, false]
      assert buttons == [[3], [1, 3], [2], [2, 3], [0, 2], [0, 1]]
      assert joltage == [3, 5, 4, 7]
    end
  end

  describe "min_light_presses (Part 1)" do
    test "first machine requires 2 presses" do
      machine = {[false, true, true, false], [[3], [1, 3], [2], [2, 3], [0, 2], [0, 1]]}
      assert @day_module.min_light_presses(machine) == 2
    end

    test "second machine requires 3 presses" do
      machine =
        {[false, false, false, true, false],
         [[0, 2, 3, 4], [2, 3], [0, 4], [0, 1, 2], [1, 2, 3, 4]]}

      assert @day_module.min_light_presses(machine) == 3
    end

    test "third machine requires 2 presses" do
      machine =
        {[false, true, true, true, false, true],
         [[0, 1, 2, 3, 4], [0, 3, 4], [0, 1, 2, 4, 5], [1, 2]]}

      assert @day_module.min_light_presses(machine) == 2
    end
  end

  describe "min_joltage_presses (Part 2)" do
    test "first machine requires 10 presses" do
      buttons = [[3], [1, 3], [2], [2, 3], [0, 2], [0, 1]]
      targets = [3, 5, 4, 7]
      assert @day_module.min_joltage_presses(buttons, targets) == 10
    end

    test "second machine requires 12 presses" do
      buttons = [[0, 2, 3, 4], [2, 3], [0, 4], [0, 1, 2], [1, 2, 3, 4]]
      targets = [7, 5, 12, 7, 2]
      assert @day_module.min_joltage_presses(buttons, targets) == 12
    end

    test "third machine requires 11 presses" do
      buttons = [[0, 1, 2, 3, 4], [0, 3, 4], [0, 1, 2, 4, 5], [1, 2]]
      targets = [10, 11, 11, 5, 10, 5]
      assert @day_module.min_joltage_presses(buttons, targets) == 11
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
