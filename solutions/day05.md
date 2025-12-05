# Day 05: Cafeteria

> [Link to puzzle](https://adventofcode.com/2025/day/5)

## Problem Summary

### Part 1

Given a database of fresh ingredient ID ranges and a list of available ingredient IDs, count how many available IDs fall within any fresh range. Ranges are inclusive and can overlap.

### Part 2

Count the total number of unique ingredient IDs that would be considered fresh across all ranges. Since ranges can overlap, we need to avoid double-counting.

---

## Solution Development

### Understanding the Problem

**Inputs:**
- Section 1: Fresh ID ranges in "start-end" format (e.g., "3-5" means IDs 3, 4, 5)
- Section 2: Available ingredient IDs to check

**Constraints:**
- Ranges are inclusive
- Ranges can overlap
- Part 2 ranges span up to 10^14 values - cannot enumerate

**Edge Cases:**
- Overlapping ranges (12-18 overlaps with both 10-14 and 16-20)
- Adjacent ranges (should be merged for Part 2)
- Single-value ranges (e.g., "5-5")

### Approach

**Part 1: Range Membership**

Simple approach: for each ID, check if it falls within any range.

**Key Insight:** Elixir's `in` operator with `Range` is O(1) - it uses arithmetic comparison, not iteration.

**Part 2: Interval Merging**

Cannot enumerate all IDs (ranges too large). Instead:
1. Sort ranges by start value
2. Merge overlapping/adjacent ranges using a fold
3. Sum `(end - start + 1)` for each merged range

**Key Insight:** Two ranges overlap or touch if `new_start <= current_end + 1`. The merged range is `current_start..max(current_end, new_end)`.

**Alternative Approaches Considered:**

- **Set union**: Would work for small ranges but impossible for 10^14 element ranges
- **Coordinate compression**: Viable but more complex than interval merging

### Implementation

#### Parsing

```elixir
def parse(input) do
  [ranges_section, ids_section] = paragraphs(input)

  ranges = ranges_section |> lines() |> Enum.flat_map(&extract_ranges/1)
  ids = ids_section |> lines() |> Enum.map(&String.to_integer/1)

  {ranges, ids}
end
```

Used the new `extract_ranges/1` helper added to `Aoc2025.Day.Helpers` - treats hyphen as delimiter rather than negative sign.

#### Part 1 Solution

```elixir
defp solve_part1({ranges, ids}) do
  ids |> Enum.count(&fresh?(&1, ranges))
end

defp fresh?(id, ranges) do
  Enum.any?(ranges, fn range -> id in range end)
end
```

**Complexity:** O(n * m) where n = number of IDs, m = number of ranges

#### Part 2 Solution

```elixir
defp solve_part2({ranges, _ids}) do
  ranges
  |> merge_ranges()
  |> Enum.map(&range_size/1)
  |> Enum.sum()
end

defp merge_ranges(ranges) do
  ranges
  |> Enum.sort_by(fn first.._//_ -> first end)
  |> Enum.reduce([], &merge_into/2)
  |> Enum.reverse()
end

defp merge_into(range, []), do: [range]

defp merge_into(new_start..new_end//_, [current_start..current_end//_ | rest])
     when new_start <= current_end + 1 do
  [current_start..max(current_end, new_end) | rest]
end

defp merge_into(range, acc), do: [range | acc]
```

**Complexity:** O(m log m) for sorting + O(m) for merging = O(m log m)

---

## Results

| Part | Example | Puzzle | Time |
|------|---------|--------|------|
| 1    | 3       | 737    | <1ms |
| 2    | 14      | 357,485,433,193,284 | <1ms |

---

## Lessons Learned

### Elixir Patterns Used

- **Multi-clause functions with guards**: `merge_into/2` uses three clauses for base case, overlap case, and gap case
- **Range pattern matching with step**: Elixir 1.19+ requires `first..last//_` syntax in patterns
- **`Enum.flat_map/2`**: Perfect for extractors that return lists - flattens automatically
- **Fold/reduce for accumulation**: Building merged ranges using `Enum.reduce/3`

### What Went Well

- The `extract_ranges/1` helper is now available for future puzzles with similar input formats
- Interval merging is a clean O(m log m) solution that handles arbitrarily large ranges

### What Was Challenging

- Initial parsing used `extract_integers/1` which treated "-" as negative sign
- Elixir 1.19 deprecation warnings for range patterns without explicit step

### Potential Improvements

- Could parallelize Part 1 with `Task.async_stream/3` for very large ID lists
- Could use interval trees for O(log m) per-query if Part 1 had many more IDs

---

## Related Concepts

- [Interval merging algorithm](https://en.wikipedia.org/wiki/Interval_scheduling)
- [Elixir Range module](https://hexdocs.pm/elixir/Range.html)
- Similar to: AoC 2022 Day 4 (range overlap detection)
