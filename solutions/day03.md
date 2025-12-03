# Day 03: Lobby Puzzle

> [Link to puzzle](https://adventofcode.com/2025/day/3)

## Problem Summary

### Part 1

Given lines of single-digit numbers (1-9) representing battery joltages, select exactly **2 batteries** per line to form a two-digit number (in order). Find the maximum joltage for each line and sum them all.

### Part 2

Same problem, but select exactly **12 batteries** per line to form a 12-digit number.

---

## Solution Development

### Understanding the Problem

- **Input:** Lines of digits 1-9 (each line is a "battery bank")
- **Output:** Sum of maximum k-digit numbers achievable from each line
- **Key constraint:** Selected digits maintain their relative order (no rearranging)

For example, from `987654321111111`:
- Part 1 (k=2): Best is `98` (positions 0, 1)
- Part 2 (k=12): Best is `987654321111` (drop the last 3 ones)

### Approach

Both parts are instances of the classic "select k elements from n to form maximum number" problem.

**Key Insights:**

1. **Greedy works:** For each position in the result, greedily pick the largest available digit that still leaves enough digits for remaining positions
2. **Constraint formula:** For position j (0-indexed), we can pick from indices `[prev+1, n-k+j]` where `prev` is the index of the previously selected digit
3. **Part 1 optimization:** When k=2, we can use suffix maximums for O(n) instead of the general O(nk) greedy approach

**Why Greedy Works:**

The leftmost digit has the highest place value, so maximizing it first is always optimal. Once we've committed to a digit at position i, the remaining problem is independent of earlier choices.

**Alternative Approaches Considered:**

- **Brute force O(n choose k):** Exponential, not feasible for k=12
- **DP approach:** Possible but greedy is simpler and sufficient

### Implementation

#### Parsing

```elixir
def parse(input) do
  input
  |> lines()
  |> Enum.map(&parse_bank/1)
end

defp parse_bank(line) do
  line
  |> String.graphemes()
  |> Enum.map(&String.to_integer/1)
end
```

Simple: split into lines, then split each line into individual digits.

#### Part 1 Solution

```elixir
def max_joltage(digits) do
  suffix_maxes = compute_suffix_maxes(digits)

  digits
  |> Enum.zip(suffix_maxes)
  |> Enum.filter(fn {_d, max_after} -> max_after > 0 end)
  |> Enum.map(fn {d, max_after} -> d * 10 + max_after end)
  |> Enum.max()
end

defp compute_suffix_maxes(digits) do
  {suffix_maxes, _} =
    digits
    |> Enum.reverse()
    |> Enum.map_reduce(0, fn d, max_after ->
      {max_after, max(d, max_after)}
    end)

  Enum.reverse(suffix_maxes)
end
```

**Complexity:** O(n) time, O(n) space

The suffix maximum array lets us answer "what's the largest digit after position i?" in O(1). We filter out positions where `max_after = 0` (last position has no valid second digit).

#### Part 2 Solution

```elixir
def max_joltage_k(digits, k) do
  digits_tuple = List.to_tuple(digits)
  n = tuple_size(digits_tuple)

  select_k_digits(digits_tuple, n, k, 0, 0, [])
  |> Enum.reverse()
  |> Integer.undigits()
end

defp select_k_digits(_digits, _n, k, k, _prev, acc), do: acc

defp select_k_digits(digits, n, k, j, prev, acc) do
  end_idx = n - k + j
  {max_digit, max_idx} = find_max_in_range(digits, prev, end_idx)
  select_k_digits(digits, n, k, j + 1, max_idx + 1, [max_digit | acc])
end
```

**Complexity:** O(n * k) time, O(k) space

For each of the k positions, we scan a shrinking window to find the maximum digit. Could be optimized to O(n) using a monotonic deque, but O(nk) is sufficient for AoC inputs.

---

## Results

| Part | Example | Puzzle | Time |
|------|---------|--------|------|
| 1    | ✓ 357   | 17031  | <1ms |
| 2    | ✓ 3121910778619 | 168575096286051 | ~2ms |

---

## Lessons Learned

### Elixir Patterns Used

- **`Enum.map_reduce/3`:** Build suffix max array in one pass, tracking both the output and running maximum
- **`List.to_tuple/1`:** Convert list to tuple for O(1) indexed access in the greedy algorithm
- **`Integer.undigits/1`:** Convert list of digits back to integer - the inverse of `Integer.digits/1`
- **Tail recursion with accumulator:** `select_k_digits` builds result in reverse, then reverses at the end

### What Went Well

- Recognized the classic "select k elements for max number" pattern immediately
- Part 1's suffix-max optimization was a nice touch for efficiency
- Clean separation between parsing, solving, and utility functions

### What Was Challenging

- **Bug in Part 1:** Initially forgot to filter out positions where `suffix_max = 0`, which incorrectly considered the last position as a valid "first digit" even though there's no second digit after it

### Potential Improvements

- **Monotonic deque:** Could optimize Part 2 from O(nk) to O(n) using a sliding window maximum structure
- **Generalize Part 1:** Could rewrite `max_joltage/1` to use `max_joltage_k(digits, 2)` for consistency

---

## Related Concepts

- [Greedy algorithms](https://en.wikipedia.org/wiki/Greedy_algorithm) - When local optimal choices lead to global optimum
- [Suffix arrays](https://en.wikipedia.org/wiki/Suffix_array) - Related concept for string problems
- [`Integer.undigits/1`](https://hexdocs.pm/elixir/Integer.html#undigits/2) - Elixir function for converting digit lists
- [`Enum.map_reduce/3`](https://hexdocs.pm/elixir/Enum.html#map_reduce/3) - Combine map and reduce in one pass
