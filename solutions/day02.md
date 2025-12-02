# Day 2: Gift Shop

> [Link to puzzle](https://adventofcode.com/2025/day/2)

## Problem Summary

### Part 1

Find all "invalid" product IDs within given ranges, where an invalid ID is any number made of a digit sequence **repeated exactly twice** (e.g., `55`, `6464`, `123123`). Return the sum of all invalid IDs.

### Part 2

Extends the definition: an invalid ID is now any number made of a digit sequence **repeated at least twice** (e.g., `111` = 1 three times, `121212` = 12 three times). Same goal: sum all invalid IDs.

---

## Solution Development

### Understanding the Problem

- **Input:** Single line of comma-separated ranges like `11-22,95-115,...`
- **Constraints:**
  - Ranges can be quite large (hundreds of thousands of numbers)
  - No leading zeros in IDs
  - Need to handle very large numbers (10+ digits)
- **Edge cases:**
  - Numbers with odd digit counts can't be doubled (Part 1 only)
  - Same number could be found via multiple patterns in Part 2 (e.g., `111111` = 1×6, 11×3, or 111×2)

### Approach

**Key Insight: Mathematical Generation**

Rather than checking every number in a range (which could be millions), we exploit the mathematical structure of "doubled" numbers.

A k-digit pattern `n` repeated `m` times equals:
```
n × repunit(k, m)
```

Where `repunit(k, m) = (10^(k×m) - 1) / (10^k - 1)`

Examples:
- `64 × 101 = 6464` (k=2, m=2, repunit = 101)
- `123 × 1001 = 123123` (k=3, m=2, repunit = 1001)
- `56 × 10101 = 565656` (k=2, m=3, repunit = 10101)

This transforms the problem from "check every number" to "find valid bases within a derived range."

**Alternative Approaches Considered:**

- **Naive iteration:** Check each number in range, test if string first-half equals second-half. Works for small ranges but too slow for large ones.
- **String-based generation:** Generate patterns and concatenate strings. More memory-intensive and slower than pure arithmetic.

### Implementation

#### Parsing

```elixir
def parse(input) do
  input
  |> String.trim()
  |> String.split(",", trim: true)
  |> Enum.map(&parse_range/1)
end

defp parse_range(range_str) do
  [start, stop] =
    range_str
    |> String.split("-")
    |> Enum.map(&String.to_integer/1)
  {start, stop}
end
```

Simple pipeline: split on commas, then split each range on dash and convert to integer tuple.

#### Part 1 Solution

```elixir
defp find_doubled_in_range(k, start, stop) do
  # A k-digit base n produces doubled number: n × (10^k + 1)
  multiplier = Integer.pow(10, k) + 1
  {min_base, max_base} = base_range(k)

  # Find n values where n × multiplier is in [start, stop]
  range_min = ceiling_div(start, multiplier)
  range_max = div(stop, multiplier)

  # Intersect with valid base range
  actual_min = max(min_base, range_min)
  actual_max = min(max_base, range_max)

  if actual_min <= actual_max do
    Enum.map(actual_min..actual_max, &(&1 * multiplier))
  else
    []
  end
end
```

**Complexity:** O(D × R) where D = number of digit lengths to check, R = doubled numbers found per range. Much better than O(range_size).

**Algorithm walkthrough:**
1. For a doubled number with k-digit base, the multiplier is `10^k + 1`
2. Using division, find which base values produce numbers in our range
3. Intersect with valid base range (k-digit numbers: `10^(k-1)` to `10^k - 1`)
4. Generate actual doubled numbers by multiplying

#### Part 2 Solution

```elixir
defp repunit(k, m) do
  total = k * m
  div(Integer.pow(10, total) - 1, Integer.pow(10, k) - 1)
end

defp solve_part2(ranges) do
  ranges
  |> Enum.flat_map(&find_invalid_ids_v2/1)
  |> MapSet.new()  # Deduplicate!
  |> Enum.sum()
end
```

**Complexity:** O(D² × R) due to checking all (k, m) combinations, still much better than naive.

**Key change:** Now we iterate over all valid `(k, m)` pairs where `k × m ≤ max_digits` and `m ≥ 2`. The `repunit` function generalizes the multiplier formula. **MapSet is crucial** to avoid counting numbers like `111111` multiple times.

---

## Results

| Part | Example | Puzzle | Time |
|------|---------|--------|------|
| 1    | ✓ 1,227,775,554 | 38,310,256,125 | <1ms |
| 2    | ✓ 4,174,379,265 | 58,961,152,806 | <1ms |

---

## Lessons Learned

### Elixir Patterns Used

- **`Integer.pow/2`:** Built-in integer exponentiation avoids floating-point precision issues
- **Multi-clause functions with guards:** `base_range(1)` vs `base_range(k)` for clean special-case handling
- **List comprehensions with multiple generators:** `for k <- ..., m <- ..., id <- ...` elegantly handles nested iteration
- **MapSet for deduplication:** Essential for Part 2 where same number can be found multiple ways
- **Capture operator `&`:** `&(&1 * multiplier)` for concise anonymous functions

### What Went Well

- Mathematical approach paid off immediately - sub-millisecond execution even for large ranges
- Part 2 extension was straightforward once Part 1's structure was in place
- Repunit formula generalized nicely from the Part 1 special case

### What Was Challenging

- Initially considered naive string-based checking before recognizing the mathematical pattern
- Needed to remember deduplication for Part 2 (same number via different (k,m) pairs)

### Potential Improvements

- Could parallelize range processing with `Task.async_stream` for very large inputs
- Could add early termination if a range contains no valid digit lengths

---

## Related Concepts

- [Repunit numbers](https://en.wikipedia.org/wiki/Repunit) - numbers consisting of repeated 1s
- [Integer.pow/2](https://hexdocs.pm/elixir/Integer.html#pow/2) - Elixir's integer exponentiation
- [MapSet](https://hexdocs.pm/elixir/MapSet.html) - Elixir's hash set implementation
