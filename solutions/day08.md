# Day 8: Playground

> [Link to puzzle](https://adventofcode.com/2025/day/8)

## Problem Summary

### Part 1

Given 3D coordinates of junction boxes, we need to connect the **1000 closest pairs** (by straight-line distance). After making these connections, find the **product of the sizes of the three largest circuits**.

When two boxes are connected, they form a circuit. If they're already in the same circuit, nothing happens.

### Part 2

Continue connecting junction boxes until **all boxes form a single circuit**. Return the **product of the X coordinates** of the last two boxes that were connected to complete the single circuit.

---

## Solution Development

### Understanding the Problem

This is a classic **Union-Find (Disjoint Set Union)** problem with elements of **Kruskal's Minimum Spanning Tree** algorithm:

- **Input**: N points in 3D space (junction boxes)
- **Operation**: Connect pairs by distance, tracking which connected components (circuits) they belong to
- **Part 1**: After K connections, what are the sizes of the components?
- **Part 2**: Which connection finally merges all components into one?

**Key Insight**: We're essentially building a minimum spanning tree by processing edges (pairs) in order of distance. Part 1 asks about component sizes after 1000 edges, Part 2 asks for the (N-1)th edge that actually merges components.

### Approach

**Union-Find** is perfect here because:
1. We need to track which boxes are in the same circuit
2. We need efficient "merge" operations
3. We need to detect when a merge is redundant (same circuit)

**Algorithm:**
1. Calculate all pairwise distances (use squared distance to avoid sqrt)
2. Sort pairs by distance
3. Process pairs in order, using Union-Find to track circuits
4. Part 1: Stop after 1000 pairs, count circuit sizes
5. Part 2: Track last pair that merged two different circuits

### Implementation

#### Parsing

Simple comma-separated 3D coordinates:

```elixir
defp parse_coord(line) do
  [x, y, z] = line |> String.split(",") |> Enum.map(&String.to_integer/1)
  {x, y, z}
end
```

#### Distance Calculation

Using **squared Euclidean distance** to avoid expensive sqrt operations (ordering is preserved):

```elixir
defp distance_squared({x1, y1, z1}, {x2, y2, z2}) do
  dx = x2 - x1
  dy = y2 - y1
  dz = z2 - z1
  dx * dx + dy * dy + dz * dz
end
```

#### Union-Find in Elixir

The interesting challenge is implementing Union-Find functionally. In imperative languages, you'd use mutable arrays. In Elixir, we use immutable maps and thread state:

```elixir
@type uf_state :: {parent_map(), rank_map()}

defp find({parent, _rank} = uf, x) do
  if parent[x] == x do
    {x, uf}
  else
    {root, {new_parent, new_rank}} = find(uf, parent[x])
    # Path compression - update parent to point directly to root
    {root, {Map.put(new_parent, x, root), new_rank}}
  end
end
```

Note how `find/2` returns **both** the root **and** the updated state (for path compression).

#### Part 2 - Tracking Last Merge

For Part 2, we use a variant that distinguishes between "real" merges and redundant connections:

```elixir
defp try_union(uf, x, y) do
  {root_x, uf} = find(uf, x)
  {root_y, {parent, rank}} = find(uf, y)

  if root_x == root_y do
    {:same_circuit, {parent, rank}}  # No merge needed
  else
    {:merged, new_uf}  # Actually merged two circuits
  end
end
```

Then we recursively process pairs until we've had N-1 successful merges:

```elixir
defp find_last_merge(_pairs, uf, 0, last_merge), do: {uf, last_merge}

defp find_last_merge([{_dist, i, j} | rest], uf, merges_needed, last_merge) do
  case try_union(uf, i, j) do
    {:merged, new_uf} ->
      find_last_merge(rest, new_uf, merges_needed - 1, {i, j})
    {:same_circuit, new_uf} ->
      find_last_merge(rest, new_uf, merges_needed, last_merge)
  end
end
```

**Complexity:**

- Distance calculation: O(N²) pairs for N boxes
- Sorting: O(N² log N)
- Union-Find operations: Nearly O(1) each with path compression + union by rank
- **Total: O(N² log N)**

---

## Results

| Part | Example | Puzzle       | Time   |
|------|---------|--------------|--------|
| 1    | ✓ 40    | 181,584      | ~10ms  |
| 2    | ✓ 25272 | 8,465,902,405| ~300ms |

---

## Lessons Learned

### Elixir Patterns Used

- **Functional Union-Find**: Threading state through recursive calls instead of mutation
- **Tagged tuples**: `{:merged, state}` vs `{:same_circuit, state}` for clear control flow
- **Squared distance optimization**: Avoid sqrt when only comparing relative distances
- **Comprehensions for pairs**: `for i <- 0..(n-2), j <- (i+1)..(n-1) do` generates all unique pairs

### What Went Well

- Union-Find maps directly to Elixir's functional style with minor adaptations
- Pattern matching makes the "merge vs same circuit" logic very clean
- Type specs helped catch issues during development

### What Was Challenging

- Remembering that Union-Find `find` must return updated state for path compression
- In Elixir, we can't do in-place path compression, so state threading is essential

### Potential Improvements

- Could use `:ets` table for O(1) mutable lookups if performance critical
- Could parallelize distance calculations with `Task.async_stream`

---

## Related Concepts

- [Union-Find / Disjoint Set Union](https://en.wikipedia.org/wiki/Disjoint-set_data_structure)
- [Kruskal's Algorithm](https://en.wikipedia.org/wiki/Kruskal%27s_algorithm) - This problem is essentially finding specific edges in an MST construction
- [AoC 2019 Day 3](https://adventofcode.com/2019/day/3) - Another distance/intersection problem
