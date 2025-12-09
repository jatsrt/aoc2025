# Day 09: Movie Theater

> [Link to puzzle](https://adventofcode.com/2025/day/9)

## Problem Summary

### Part 1

Given a list of red tile coordinates on a grid, find the largest rectangle that uses two red tiles as opposite corners. The rectangle is axis-aligned (sides parallel to x and y axes).

### Part 2

The rectangle must now only include **red or green tiles**. Green tiles are:
1. Lines connecting consecutive red tiles in the input (wrapping around)
2. All tiles inside the closed polygon formed by the boundary

This means we're looking for the largest rectangle that fits entirely within (or on the boundary of) the polygon defined by the red tiles.

---

## Solution Development

### Understanding the Problem

**Inputs:**
- A list of coordinates representing red tiles
- Coordinates are given as `x,y` pairs

**Part 1 Constraints:**
- Any two red tiles can form opposite corners of a rectangle
- The rectangle includes the corner tiles (inclusive area)

**Part 2 Constraints:**
- Red tiles form vertices of a rectilinear polygon (edges are axis-aligned)
- Consecutive red tiles in the input are connected by straight lines (green tiles)
- The polygon is closed (last tile connects to first)
- The rectangle must stay entirely within the valid region

### Approach

**Part 1: Brute Force O(n²)**

For each pair of red tiles, calculate the rectangle area. The area formula for corners at `(x1, y1)` and `(x2, y2)` is:
```
area = (|x2 - x1| + 1) × (|y2 - y1| + 1)
```
Note: The `+1` is because the rectangle **includes** both corner tiles.

**Part 2: Scanline Algorithm + Row Range Validation**

The key insight is that for a rectilinear polygon, we can efficiently determine valid ranges for each row:

1. Build a map of `y -> (min_x, max_x)` for each row in the polygon
2. For each pair of red tiles, check if their rectangle fits within the valid ranges for every row it spans

This avoids the expensive O(width × height) per-rectangle check.

**Key Insights:**

1. **Inclusive rectangles**: The problem counts tiles, not gaps. A rectangle from `(2,1)` to `(11,5)` has 10×5=50 tiles, not 9×4=36.

2. **Rectilinear polygon representation**: Instead of storing millions of individual valid tiles, we store just the min/max x range per row. This is O(height) storage instead of O(area).

3. **Rectangle validation**: To check if a rectangle is valid, we only need to verify that for each row in its y-range, the rectangle's x-range is contained within that row's valid x-range.

**Alternative Approaches Considered:**

- **MapSet of all valid tiles**: Works for small inputs but too slow/memory-heavy for large grids
- **Per-tile ray casting**: Correct but O(width × height × edges) is too slow
- **Flood fill for interior**: Also too slow for large coordinate ranges

### Implementation

#### Parsing

```elixir
def parse(input) do
  input
  |> lines()
  |> Enum.map(&parse_coord/1)
end

defp parse_coord(line) do
  [x, y] = extract_integers(line)
  {x, y}
end
```

Simple extraction of integer pairs from each line.

#### Part 1 Solution

```elixir
def find_max_rectangle_area(coords) do
  for {x1, y1} <- coords,
      {x2, y2} <- coords,
      x1 != x2 and y1 != y2,
      reduce: 0 do
    acc ->
      width = abs(x2 - x1) + 1
      height = abs(y2 - y1) + 1
      area = width * height
      max(acc, area)
  end
end
```

**Complexity:** O(n²) time, O(1) space

Uses Elixir's `for` comprehension with `:reduce` to find the maximum area across all pairs.

#### Part 2 Solution

```elixir
def build_row_ranges(red_tiles) do
  # Extract vertical and horizontal edges
  edges = build_edges(red_tiles)

  vertical_edges = filter_vertical(edges)
  horizontal_edges = filter_horizontal(edges)

  # For each row, compute valid x range
  for y <- min_y..max_y, into: %{} do
    {x_min, x_max} = compute_row_range(y, vertical_edges, horizontal_edges)
    {y, {x_min, x_max}}
  end
end

defp rectangle_valid_fast?({x1, y1}, {x2, y2}, row_ranges) do
  {rect_x_min, rect_x_max} = Enum.min_max([x1, x2])
  {y_min, y_max} = Enum.min_max([y1, y2])

  Enum.all?(y_min..y_max, fn y ->
    case Map.get(row_ranges, y) do
      {row_x_min, row_x_max} ->
        rect_x_min >= row_x_min and rect_x_max <= row_x_max
      nil ->
        false
    end
  end)
end
```

**Complexity:**
- Building row ranges: O(height × edges)
- Rectangle validation: O(n² × height) total

---

## Results

| Part | Example | Puzzle          | Time   |
|------|---------|-----------------|--------|
| 1    | 50      | 4,735,222,687   | <1ms   |
| 2    | 24      | 1,569,262,188   | ~32s   |
| 2 (optimized) | 24 | 1,569,262,188 | ~3s |

---

## Advanced Optimization: Sparse Table + Parallelization

The standard Part 2 solution is correct but slow (~32 seconds). We implemented an optimized version demonstrating two powerful techniques:

### The Bottleneck

The standard approach validates each rectangle by iterating through every row:
```elixir
# O(height) per rectangle - slow for tall rectangles!
Enum.all?(y_min..y_max, fn y ->
  row_contains_x_range?(row_ranges, y, rect_x_min, rect_x_max)
end)
```

With ~250,000 pairs and rectangles spanning up to ~50,000 rows, this is O(n² × height).

### Optimization 1: Sparse Table for O(1) Range Queries

The rectangle validation question is really asking:
- Is `max(min_x[y] for y in range) <= rect_x_min`?
- Is `min(max_x[y] for y in range) >= rect_x_max`?

These are **range-max** and **range-min** queries - a classic computer science problem with an elegant solution: **Sparse Tables**.

#### How Sparse Tables Work

A sparse table precomputes answers for all power-of-2 sized ranges:

```
Level 0: [a₀] [a₁] [a₂] [a₃] [a₄] [a₅] [a₆] [a₇]  (ranges of size 1)
Level 1: [max(a₀,a₁)] [max(a₁,a₂)] ... (ranges of size 2)
Level 2: [max(a₀..a₃)] [max(a₁..a₄)] ... (ranges of size 4)
...
```

To query any range [l, r], find the largest k where 2^k ≤ length, then:
```elixir
max(table[k][l], table[k][r - 2^k + 1])
```

Since both ranges overlap and cover [l, r], this gives the correct answer in **O(1)**!

```elixir
defp build_sparse_table(arr, n, combine_fn) do
  max_k = floor(:math.log2(n))
  initial = %{0 => arr}

  Enum.reduce(1..max_k//1, initial, fn k, table ->
    prev = table[k - 1]
    step = Bitwise.bsl(1, k - 1)  # 2^(k-1)

    level_k =
      for i <- 0..(n - Bitwise.bsl(1, k))//1, into: %{} do
        {i, combine_fn.(prev[i], prev[i + step])}
      end

    Map.put(table, k, level_k)
  end)
end
```

### Optimization 2: Parallel Processing with Task.async_stream

The pair checking is "embarrassingly parallel" - each pair is independent. We chunk the work and distribute across CPU cores:

```elixir
pairs
|> Enum.chunk_every(chunk_size)
|> Task.async_stream(
  fn chunk ->
    Enum.reduce(chunk, 0, fn {p1, p2}, acc ->
      if rectangle_fits_sparse?(p1, p2, ...) do
        max(acc, rectangle_area(p1, p2))
      else
        acc
      end
    end)
  end,
  timeout: :infinity,
  ordered: false
)
|> Enum.reduce(0, fn {:ok, chunk_max}, acc -> max(acc, chunk_max) end)
```

### Performance Comparison

| Approach | Validation | Complexity | Time |
|----------|------------|------------|------|
| Standard | O(height) | O(n² × height) | 32s |
| Optimized | O(1) | O(n² / cores) | 3s |

**Speedup: 10.7x**

---

## Lessons Learned

### Elixir Patterns Used

- **`for` with `:reduce`**: Clean way to iterate over pairs and accumulate a result
- **`Enum.chunk_every/4`**: Perfect for pairing consecutive elements with wrap-around
- **`Enum.min_max/1`**: Convenient for getting both bounds in one pass
- **Pattern matching in function heads**: Used for filtering edge types
- **`Task.async_stream`**: Distributes work across CPU cores with back-pressure
- **`Bitwise.bsl/2`**: Efficient power-of-2 calculations using bit shifts

### What Went Well

- Part 1 was straightforward once I understood the inclusive area calculation
- The scanline approach for Part 2 is elegant and efficient
- The sparse table optimization demonstrates that algorithmic improvements often outweigh parallelization

### What Was Challenging

- **Initial Part 2 approach was too slow**: First tried storing all valid tiles in a MapSet, which was O(area) and wouldn't complete
- **Off-by-one in area calculation**: Initially forgot the +1 for inclusive rectangles
- **Sparse table indexing**: Converting between y-coordinates and 0-indexed array positions required care

### Key Takeaway

When optimizing, consider **both**:
1. **Algorithmic improvements** (Sparse Table: O(height) → O(1) validation)
2. **Parallelization** (Task.async_stream: divide work across cores)

The combination gave us 10x+ speedup!

---

## Related Concepts

- [Sparse Table (CP-Algorithms)](https://cp-algorithms.com/data_structures/sparse-table.html)
- [Range Minimum Query](https://en.wikipedia.org/wiki/Range_minimum_query)
- [Point-in-polygon algorithms](https://en.wikipedia.org/wiki/Point_in_polygon)
- [Scanline rendering](https://en.wikipedia.org/wiki/Scanline_rendering)
- [Rectilinear polygons](https://en.wikipedia.org/wiki/Rectilinear_polygon)
- [Elixir Task.async_stream](https://hexdocs.pm/elixir/Task.html#async_stream/3)
- [Elixir Bitwise](https://hexdocs.pm/elixir/Bitwise.html)
