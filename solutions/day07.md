# Day 7: Laboratories

> [Link to puzzle](https://adventofcode.com/2025/day/7)

## Problem Summary

### Part 1

Simulate tachyon beams traveling through a manifold with splitters:
- A beam enters at position `S` and travels **downward**
- When a beam hits a splitter (`^`), it stops and two new beams continue from the **left and right**
- Multiple beams can merge when they occupy the same column
- Count the total number of times a beam is **split**

### Part 2

Apply the "many-worlds interpretation" - each split creates two distinct timelines:
- One timeline where the particle went left
- One timeline where the particle went right
- Unlike Part 1, paths don't merge even if they reach the same column
- Count the total number of **timelines** after the particle completes all possible journeys

---

## Solution Development

### Understanding the Problem

**Inputs:**
- A 2D grid with:
  - `S` marking the beam entry point
  - `^` marking splitter positions
  - `.` as empty space

**Constraints:**
- Beams only travel downward
- Splitters emit left AND right simultaneously
- In Part 2, each path is tracked separately (exponential growth)

**Edge Cases:**
- Beams exiting the left/right boundaries
- Multiple beams hitting adjacent splitters creating merged outputs

### Approach

The key insight is that we can process the manifold **row by row** instead of simulating individual beam particles:

**Part 1:** Track which columns have active beams using a `MapSet`. When beams hit splitters, update the set. Count each splitter hit as a split.

**Part 2:** Track **counts** of particles per column using a `Map`. When particles hit splitters, the count splits into left/right. Final answer is the sum of all counts.

**Key Insights:**

1. **Row-by-row processing** - We don't need to track vertical beam paths, just which columns are "active" at each row
2. **Merging vs Counting** - Part 1 uses `MapSet` (beams merge), Part 2 uses `Map` with counts (timelines stay separate)
3. **Exponential growth** - Part 2 demonstrates why tracking counts is essential: ~73 trillion timelines would be impossible to enumerate individually

**Alternative Approaches Considered:**

- **Full particle simulation**: Would work for Part 1 but be impractical for Part 2's exponential timelines
- **Recursive tree traversal**: Elegant but stack depth would explode for Part 2

### Implementation

#### Parsing

```elixir
def parse(input) do
  rows = lines(input)
  width = rows |> hd() |> String.length()

  {start_col, splitter_rows} =
    rows
    |> Enum.reduce({nil, []}, fn row, {start, acc} ->
      splitter_cols = find_chars(row, "^")
      new_start = case find_chars(row, "S") do
        [col] -> col
        [] -> start
      end
      {new_start, [splitter_cols | acc]}
    end)

  %{start: start_col, rows: Enum.reverse(splitter_rows), width: width}
end
```

We extract the starting column, width, and for each row, the list of splitter column positions. This gives us O(1) lookup for splitters per row.

#### Part 1 Solution

```elixir
defp count_splits(%{start: start, rows: rows, width: width}) do
  initial_beams = MapSet.new([start])

  rows
  |> Enum.reduce({initial_beams, 0}, fn splitter_cols, {beams, splits} ->
    process_row(beams, splitter_cols, width, splits)
  end)
  |> elem(1)
end

defp process_row(beams, splitter_cols, width, splits) do
  splitters_hit = Enum.filter(splitter_cols, &MapSet.member?(beams, &1))
  new_splits = splits + length(splitters_hit)

  new_beams =
    splitters_hit
    |> Enum.reduce(beams, fn col, acc ->
      acc
      |> MapSet.delete(col)
      |> maybe_add_beam(col - 1, width)
      |> maybe_add_beam(col + 1, width)
    end)

  {new_beams, new_splits}
end
```

**Complexity:** O(rows × splitters) time, O(width) space for active beams

#### Part 2 Solution

```elixir
defp solve_part2(%{start: start, rows: rows, width: width}) do
  initial_particles = %{start => 1}

  rows
  |> Enum.reduce(initial_particles, fn splitter_cols, particles ->
    process_row_quantum(particles, splitter_cols, width)
  end)
  |> Map.values()
  |> Enum.sum()
end

defp process_row_quantum(particles, splitter_cols, width) do
  splitter_set = MapSet.new(splitter_cols)

  particles
  |> Enum.reduce(%{}, fn {col, count}, acc ->
    if MapSet.member?(splitter_set, col) do
      acc
      |> add_particles(col - 1, count, width)
      |> add_particles(col + 1, count, width)
    else
      Map.update(acc, col, count, &(&1 + count))
    end
  end)
end
```

The only structural change from Part 1 is using `Map` with counts instead of `MapSet`. This elegantly handles the exponential growth without actually enumerating each timeline.

**Complexity:** O(rows × active_columns) time, O(width) space

---

## Results

| Part | Example | Puzzle | Time |
|------|---------|--------|------|
| 1    | 21 | 1,581 | <1ms |
| 2    | 40 | 73,007,003,089,792 | <1ms |

---

## Lessons Learned

### Elixir Patterns Used

- **MapSet vs Map**: Clean distinction between "presence tracking" (Part 1) and "count tracking" (Part 2)
- **Enum.reduce with accumulator**: Perfect for processing rows while maintaining state
- **Map.update/4**: Elegant way to increment counts with a default value
- **Guards for bounds checking**: `when col >= 0 and col < width` keeps boundary logic clean

### What Went Well

- The row-by-row approach naturally handled both parts with minimal code changes
- Part 2's solution handles 73+ trillion timelines in milliseconds by tracking counts instead of enumeration

### What Was Challenging

- Initially needed to carefully trace through the example to understand the "merge vs count" distinction between parts

### Potential Improvements

- Could use a sparse representation if the manifold were much wider with few active columns
- Could parallelize row processing if needed for very tall manifolds

---

## Related Concepts

- [Pascal's Triangle](https://en.wikipedia.org/wiki/Pascal%27s_triangle) - Similar exponential growth pattern from repeated splitting
- [MapSet documentation](https://hexdocs.pm/elixir/MapSet.html) - Elixir's set implementation used in Part 1
- [Many-worlds interpretation](https://en.wikipedia.org/wiki/Many-worlds_interpretation) - The quantum mechanics concept referenced in Part 2
