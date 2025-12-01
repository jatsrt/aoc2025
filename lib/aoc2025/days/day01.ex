defmodule Aoc2025.Days.Day01 do
  @moduledoc """
  # Day 1: Secret Entrance

  Track a safe's dial rotations to determine the password. The dial displays
  numbers 0-99 in a circle, starting at position 50.

  ## Part 1

  Count how many times the dial lands on 0 during all rotations.
  - "L" moves left (subtract), "R" moves right (add)
  - Dial wraps around (0-99 is circular)

  ## Part 2

  Count how many times the dial passes through OR lands on 0 during rotations.
  This includes every "click" where the dial points at 0, even mid-rotation.
  Example: R1000 from position 50 crosses 0 exactly 10 times.

  ## Approach

  Parse each instruction into a direction and amount, then simulate the dial
  using modular arithmetic. For Part 2, calculate zero crossings by tracking
  how many times we cross the 0 boundary during each rotation.
  """

  use Aoc2025.Day

  @dial_size 100
  @start_position 50

  @doc """
  Solve Part 1: Count how many times the dial lands on 0.
  """
  @impl true
  def part1(input), do: input |> parse() |> count_zeros()

  @doc """
  Solve Part 2: Count all zero crossings (passing through or landing on 0).
  """
  @impl true
  def part2(input), do: input |> parse() |> count_all_zero_crossings()

  @doc """
  Parse the input into a list of {direction, amount} tuples.

  ## Input Format

  Each line contains a direction (L or R) followed by a number.
  Example: "L68" means rotate left 68 positions.

  ## Output Format

  List of tuples: `[{:left, 68}, {:right, 48}, ...]`
  """
  @impl true
  def parse(input), do: input |> lines() |> Enum.map(&parse_instruction/1)

  defp parse_instruction("L" <> amount), do: {:left, String.to_integer(amount)}
  defp parse_instruction("R" <> amount), do: {:right, String.to_integer(amount)}

  # --- Part 1 Implementation ---

  @doc """
  Simulate dial rotations and count how many times we land on 0.
  """
  def count_zeros(instructions) do
    {_final_position, zero_count} =
      instructions
      |> Enum.reduce({@start_position, 0}, fn instruction, {position, count} ->
        new_position = apply_rotation(position, instruction)
        new_count = if new_position == 0, do: count + 1, else: count
        {new_position, new_count}
      end)

    zero_count
  end

  defp apply_rotation(position, {:left, amount}), do: Integer.mod(position - amount, @dial_size)
  defp apply_rotation(position, {:right, amount}), do: Integer.mod(position + amount, @dial_size)

  # --- Part 2 Implementation ---

  @doc """
  Count every time the dial passes through or lands on 0 during all rotations.

  For each rotation, we calculate how many times zero is crossed by considering
  the start position, end position, and direction of travel.
  """
  def count_all_zero_crossings(instructions) do
    {_final_position, zero_count} =
      instructions
      |> Enum.reduce({@start_position, 0}, fn instruction, {position, count} ->
        crossings = count_crossings(position, instruction)
        new_position = apply_rotation(position, instruction)
        {new_position, count + crossings}
      end)

    zero_count
  end

  # Count how many times we cross/land on 0 during a single rotation.
  # Key insight: we need to count how many times we pass the 0 boundary.
  #
  # For LEFT rotation: we're decrementing, so we cross 0 when we go from
  # a positive position past 0 (wrapping to 99). Each full lap crosses once.
  #
  # For RIGHT rotation: we're incrementing, so we cross 0 when we go from
  # 99 to 0 (wrapping). Each full lap crosses once.
  # Starting at 0: only return to 0 after full laps
  defp count_crossings(0, {_direction, amount}), do: div(amount, @dial_size)

  # Going left from position P: hit 0 after P steps, then every 100
  defp count_crossings(position, {:left, amount}) when amount < position, do: 0
  defp count_crossings(position, {:left, amount}), do: 1 + div(amount - position, @dial_size)

  # Going right from position P: hit 0 after (100-P) steps, then every 100
  defp count_crossings(position, {:right, amount}) when amount < @dial_size - position, do: 0

  defp count_crossings(position, {:right, amount}),
    do: 1 + div(amount - (@dial_size - position), @dial_size)
end
