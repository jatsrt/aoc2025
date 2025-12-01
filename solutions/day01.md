# Day 1: Secret Entrance

> [Link to puzzle](https://adventofcode.com/2025/day/1)

## Problem Summary

### Part 1

A safe's dial displays numbers 0-99 in a circle, starting at position 50. Given a series of rotations (L for left/subtract, R for right/add), count how many times the dial **lands on** 0 at the end of a rotation.

### Part 2

Count how many times the dial **passes through or lands on** 0 during rotations. This includes every "click" where the dial points at 0, even mid-rotation. For example, R1000 from position 50 crosses 0 exactly 10 times.

---

## Solution Development

### Understanding the Problem

- **Input**: A list of rotation instructions, each with a direction (L/R) and an amount
- **Constraints**: Dial is circular (0-99), wraps around in both directions
- **Edge cases**:
  - Starting at 0 and moving away doesn't count as a crossing
  - Large rotations can cross 0 multiple times (R1000 crosses 10 times)

### Approach

Both parts use `Enum.reduce` to simulate the dial, tracking position and zero count through the fold. The key difference is how we count zeros:

- **Part 1**: Simply check if the final position after each rotation equals 0
- **Part 2**: Calculate mathematically how many times we cross 0 during each rotation

**Key Insights:**

1. `Integer.mod/2` correctly handles negative numbers for circular wrapping (unlike `rem/2`)
2. For Part 2, crossing 0 can be calculated without simulating each step:
   - Going left from P: first hit 0 after P steps, then every 100 steps
   - Going right from P: first hit 0 after (100-P) steps, then every 100 steps
3. Starting at 0 is a special case: you leave immediately, only returning after full 100-step laps

**Alternative Approaches Considered:**

- **Step-by-step simulation**: Would work but O(total_steps) instead of O(n_instructions)
- **Stream-based**: Could use `Stream.unfold` but `Enum.reduce` is simpler for this case

### Implementation

#### Parsing

```elixir
defp parse_instruction("L" <> amount), do: {:left, String.to_integer(amount)}
defp parse_instruction("R" <> amount), do: {:right, String.to_integer(amount)}
```

Pattern matching on string prefix elegantly splits direction from amount without regex.

#### Part 1 Solution

```elixir
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
```

**Complexity:** O(n) time, O(1) space (just tracking position and count)

#### Part 2 Solution

```elixir
# Starting at 0: only return to 0 after full laps
defp count_crossings(0, {_direction, amount}) do
  div(amount, @dial_size)
end

# Going left from position P: hit 0 after P steps, then every 100
defp count_crossings(position, {:left, amount}) when amount < position, do: 0

defp count_crossings(position, {:left, amount}) do
  1 + div(amount - position, @dial_size)
end

# Going right from position P: hit 0 after (100-P) steps, then every 100
defp count_crossings(position, {:right, amount}) when amount < @dial_size - position, do: 0

defp count_crossings(position, {:right, amount}) do
  1 + div(amount - (@dial_size - position), @dial_size)
end
```

**Complexity:** O(n) time, O(1) space

Multi-clause functions with guards replace nested if/else, making the logic explicit in function signatures.

---

## Results

| Part | Example | Puzzle | Time |
|------|---------|--------|------|
| 1    | 3       | 992    | <1ms |
| 2    | 6       | 6133   | <1ms |

---

## Lessons Learned

### Elixir Patterns Used

- **Pattern matching in function heads**: `"L" <> amount` splits strings elegantly
- **Multi-clause functions with guards**: Replaces nested conditionals, more idiomatic
- **`Enum.reduce` with tuple accumulator**: Tracks multiple state values in single pass
- **`Integer.mod/2`**: Always returns non-negative for positive divisor (vs `rem/2`)

### What Went Well

- Pattern matching made parsing trivial
- Mathematical approach to Part 2 avoids simulating millions of steps

### What Was Challenging

- Part 2 edge case: starting at 0 and moving away doesn't count as crossing
- Initial implementation used nested if/else; refactored to use guards

### Potential Improvements

- Could extract the "distance to first crossing" logic into a helper for clarity

---

## Related Concepts

- [Modular arithmetic](https://en.wikipedia.org/wiki/Modular_arithmetic) - core to circular dial logic
- [Elixir Integer.mod/2 vs rem/2](https://hexdocs.pm/elixir/Integer.html#mod/2) - critical difference for negative numbers
- [Elixir Guards](https://hexdocs.pm/elixir/patterns-and-guards.html#guards) - used for clean multi-clause functions
