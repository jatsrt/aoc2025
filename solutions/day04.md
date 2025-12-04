# Day 04: Printing Department

> [Link to puzzle](https://adventofcode.com/2025/day/4)

## Problem Summary

### Part 1

Count paper rolls (`@`) on a grid that are **accessible by forklift**. A roll is accessible if it has **fewer than 4 neighboring rolls** in its 8 adjacent positions (orthogonal + diagonal).

### Part 2

Simulate iterative removal: remove all accessible rolls, then check again (removing rolls may expose new accessible ones). Count **total rolls removed** until no more can be accessed.

---

## Solution Development

### Understanding the Problem

- **Input:** A 2D grid of `.` (empty) and `@` (paper roll) characters
- **Neighbor check:** All 8 directions (including diagonals)
- **Accessibility rule:** < 4 neighboring rolls
- **Part 2 twist:** Cascading removal until fixpoint

**Edge cases:**
- Rolls on grid edges have fewer potential neighbors (automatically fewer than 4)
- Dense clusters may have no accessible rolls initially but become accessible after outer rolls are removed

### Approach

Use a **coordinate map** (`%{{x, y} => char}`) for O(1) neighbor lookups. This is more efficient than a 2D list for random access patterns.

**Key Insights:**

1. `Map.get/3` returns `nil` for out-of-bounds coordinates, naturally handling edge cases without explicit bounds checking
2. Part 2 is a "simulation until fixpoint" pattern - keep removing until the state doesn't change
3. The `for` comprehension with pattern matching elegantly filters only roll positions

**Alternative Approaches Considered:**

- **2D list with index access**: More complex bounds checking, O(1) but clumsier
- **MapSet for rolls only**: Would need separate empty tracking for removal

### Implementation

#### Parsing

```elixir
def parse(input), do: grid(input)
```

The `grid/1` helper from `Aoc2025.Day.Helpers` converts the input into a map of `{x, y}` coordinates to single-character strings.

#### Part 1 Solution

```elixir
defp count_accessible_rolls(warehouse) do
  warehouse
  |> find_rolls()
  |> Enum.count(&accessible?(warehouse, &1))
end

defp find_rolls(warehouse) do
  for {coord, "@"} <- warehouse, do: coord
end

defp accessible?(warehouse, coord) do
  count_roll_neighbors(warehouse, coord) < 4
end
```

**Complexity:** O(n) time, O(n) space where n = grid cells

1. Find all roll positions using `for` comprehension with pattern matching
2. For each roll, count neighbors that are also rolls
3. Count rolls with < 4 neighbors

#### Part 2 Solution

```elixir
defp remove_all_accessible(warehouse, total_removed) do
  accessible = find_accessible_rolls(warehouse)

  case accessible do
    [] -> total_removed
    rolls ->
      updated_warehouse = remove_rolls(warehouse, rolls)
      remove_all_accessible(updated_warehouse, total_removed + length(rolls))
  end
end
```

**Complexity:** O(n * k) time where k = number of removal rounds, O(n) space

Tail-recursive fixpoint iteration:
1. Find all currently accessible rolls
2. If none, return total count (base case)
3. Remove them (replace `@` with `.`)
4. Recurse with updated warehouse

---

## Results

| Part | Example | Puzzle | Time |
|------|---------|--------|------|
| 1    | ✓ 13    | 1602   | <1ms |
| 2    | ✓ 43    | 9518   | ~200ms |

---

## Lessons Learned

### Elixir Patterns Used

- **Coordinate maps**: `%{{x, y} => value}` for O(1) grid lookups
- **`for` with pattern matching**: `for {coord, "@"} <- map` filters and extracts in one expression
- **Tail recursion with accumulator**: `remove_all_accessible(warehouse, total)` for efficient iteration
- **Module attribute for constants**: `@directions` defined once, reused everywhere
- **Capture operator**: `&accessible?(warehouse, &1)` creates a closure

### What Went Well

- The coordinate map approach made neighbor checking trivial - no bounds checking needed
- Clean separation between finding accessible rolls and removing them made Part 2 a natural extension

### What Was Challenging

- Initially considered whether to track removed rolls separately vs modifying the map - modifying in place (replacing with `.`) was simpler

### Potential Improvements

- Could use `Stream` for lazy evaluation if the grid were much larger
- Could parallelize the neighbor counting with `Task.async_stream` for very large grids

---

## Related Concepts

- [Conway's Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life) - similar neighbor-counting rules
- [Flood fill algorithms](https://en.wikipedia.org/wiki/Flood_fill) - related grid traversal
- [Elixir Map documentation](https://hexdocs.pm/elixir/Map.html)
