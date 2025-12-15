# Day 12: Christmas Tree Farm

> [Link to puzzle](https://adventofcode.com/2025/day/12)

## Problem Summary

### Part 1

Determine how many rectangular regions can fit all their required "present" shapes. Each shape is an irregular polyomino (5-7 cells) that can be rotated and flipped. Shapes must be placed on a grid without overlapping, but empty spaces are allowed.

### Part 2

Free star for completing all of Advent of Code 2025!

---

## Solution Development

### Understanding the Problem

This is a 2D bin packing problem with irregular shapes:

- **Input**: 6 shape definitions (polyominoes) and 1000 regions with dimensions and shape counts
- **Shapes**: Each shape is 5-7 cells in a 3x3 bounding box, with 2-8 unique orientations after rotations/flips
- **Regions**: Rectangular grids (35x35 to 50x50) that need to fit specific numbers of each shape
- **Constraint**: Shapes cannot overlap, but don't need to fill the entire grid

### Key Insights

1. **Quick Rejection**: If total shape cells > grid area, the region immediately fails. This eliminates 431 of 1000 regions instantly.

2. **Sparse Coverage**: For passing regions, the "empty budget" (grid area - shape cells) is surprisingly large (371-840 cells). This means shapes are very sparse in the grid.

3. **All Valid Regions Fit**: With such large empty budgets, all 569 regions that pass the area check can actually fit their shapes without conflict.

4. **Backtracking with Ordering**: Sort shapes by number of orientations (most constrained first) to prune the search tree early.

### Approach

```
1. Parse shapes and pre-compute all rotations/flips
2. For each region:
   a. Quick check: total_cells > grid_area? → false
   b. Build shape list sorted by constraint level
   c. Backtrack: place shapes one at a time at valid positions
   d. Return true if all shapes placed successfully
3. Count regions that can fit all shapes
```

### Implementation

#### Parsing

Shapes are parsed from visual grid representations and converted to sets of relative coordinates. Regions are parsed as `{width, height, [counts...]}`.

#### Shape Transformations

```elixir
# Generate all 8 possible orientations (4 rotations × 2 flips)
rotations = [shape, rotate_90(shape), rotate_180(shape), rotate_270(shape)]
flipped = Enum.map(rotations, &flip_horizontal/1)

(rotations ++ flipped)
|> Enum.map(&normalize/1)
|> Enum.uniq()
```

Normalization translates each orientation so its minimum row and column are both 0, enabling comparison and deduplication.

#### Backtracking

```elixir
defp backtrack_shapes([], _grid, _width, _height), do: true

defp backtrack_shapes([{_idx, orientations} | rest], grid, width, height) do
  Enum.any?(orientations, fn orientation ->
    try_all_positions(orientation, rest, grid, width, height)
  end)
end
```

For each shape, try all orientations and all valid positions (row-major order). Place the first valid position and recurse. If all shapes are placed, return true.

**Complexity:** Worst case is exponential, but with sparse grids and good ordering, most regions solve quickly.

---

## Results

| Part | Example | Puzzle | Time   |
|------|---------|--------|--------|
| 1    | ✓ 2     | 569    | ~15s   |
| 2    | N/A     | ⭐ Free | -      |

---

## Lessons Learned

### Elixir Patterns Used

- **MapSet for grids**: O(1) membership checks and set operations (union, disjoint?)
- **Task.async_stream**: Parallel processing of independent regions
- **Pattern matching in function heads**: Clean recursive backtracking
- **Pipeline transforms**: Shape rotation and normalization chains

### What Went Well

- Quick rejection based on area eliminated 43% of regions immediately
- The insight that all valid-area regions can fit was key to understanding the problem structure
- Pre-computing shape orientations avoided redundant work

### What Was Challenging

- Initial "first empty cell" heuristic failed with large empty budgets
- MapSet opaqueness caused Dialyzer warnings (resolved with `@dialyzer` annotations)
- Balancing between algorithm complexity and implementation time

### Algorithm Evolution

1. **First attempt**: "First empty cell" heuristic with skip option - too slow with large empty budgets
2. **Second attempt**: Pure position-based backtracking - also slow
3. **Final solution**: Simple backtracking with constraint-based ordering - fast enough due to sparse coverage

---

## Related Concepts

- [Polyomino packing](https://en.wikipedia.org/wiki/Polyomino) - the mathematical foundation
- [Dancing Links (DLX)](https://en.wikipedia.org/wiki/Dancing_Links) - optimal exact cover algorithm (not needed here)
- [Constraint satisfaction](https://en.wikipedia.org/wiki/Constraint_satisfaction_problem) - general problem class
