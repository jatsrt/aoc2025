# Day 11: Reactor

> [Link to puzzle](https://adventofcode.com/2025/day/11)

## Problem Summary

### Part 1

Count all distinct paths from device "you" to device "out" in a directed graph of devices. Each device has outputs connecting to other devices, and data flows only in the forward direction.

### Part 2

Count paths from "svr" to "out" that pass through **both** "dac" and "fft" (in any order). This represents finding problematic data paths that go through both the digital-to-analog converter and the FFT device.

---

## Solution Development

### Understanding the Problem

- **Input**: A directed graph where each line defines a device and its output connections
- **Constraint**: Data flows only forward (from device to its outputs) - this is a DAG
- **Part 1**: Simple path counting from source to destination
- **Part 2**: Constrained path counting through two required waypoints

### Approach

**Key Insights:**

1. **DAG Path Counting**: Since data only flows forward, this is a Directed Acyclic Graph. We can count paths efficiently using memoized recursion:
   - Base case: `count("out") = 1`
   - Recursive: `count(node) = sum of count(neighbor) for all neighbors`

2. **Decomposing Constrained Paths**: For Part 2, paths through both dac and fft can visit them in two orders:
   - `svr → dac → fft → out`
   - `svr → fft → dac → out`

   Since path counts multiply across segments, we compute:
   - `paths(svr→dac) × paths(dac→fft) × paths(fft→out)`
   - Plus: `paths(svr→fft) × paths(fft→dac) × paths(dac→out)`

3. **Memoization is Critical**: Without memoization, the exponential blowup would make this intractable. The same intermediate node may be reached via countless different paths, and we must cache results.

**Alternative Approaches Considered:**

- **BFS/DFS enumeration**: Would enumerate all paths explicitly - impossible given the answer magnitude (~388 trillion)
- **Matrix exponentiation**: Could work but overkill for this problem structure

### Implementation

#### Parsing

```elixir
def parse(input) do
  input
  |> lines()
  |> Map.new(&parse_line/1)
end

defp parse_line(line) do
  [device, outputs] = String.split(line, ": ")
  {device, String.split(outputs, " ")}
end
```

Simple key-value parsing into a map of device → list of outputs.

#### Part 1 Solution

```elixir
def count_paths(graph, start, target) do
  {count, _memo} = count_paths_memo(graph, start, target, %{})
  count
end

defp count_paths_memo(_graph, target, target, memo), do: {1, memo}

defp count_paths_memo(graph, node, target, memo) do
  case Map.fetch(memo, node) do
    {:ok, count} -> {count, memo}
    :error ->
      neighbors = Map.get(graph, node, [])
      {count, updated_memo} =
        Enum.reduce(neighbors, {0, memo}, fn neighbor, {acc, current_memo} ->
          {n, new_memo} = count_paths_memo(graph, neighbor, target, current_memo)
          {acc + n, new_memo}
        end)
      {count, Map.put(updated_memo, node, count)}
  end
end
```

**Complexity:** O(V + E) time, O(V) space where V = vertices, E = edges

The memoization ensures each node is computed exactly once.

#### Part 2 Solution

```elixir
def count_paths_through_both(graph, start, target, via1, via2) do
  via1_first =
    count_paths(graph, start, via1) *
      count_paths(graph, via1, via2) *
      count_paths(graph, via2, target)

  via2_first =
    count_paths(graph, start, via2) *
      count_paths(graph, via2, via1) *
      count_paths(graph, via1, target)

  via1_first + via2_first
end
```

**Complexity:** O(V + E) time total (6 path queries, each O(V + E) but with shared structure)

The key insight is that path counts are multiplicative across independent segments.

---

## Results

| Part | Example | Puzzle           | Time   |
|------|---------|------------------|--------|
| 1    | 5       | 699              | <1ms   |
| 2    | 2       | 388,893,655,378,800 | <1ms   |

---

## Lessons Learned

### Elixir Patterns Used

- **Pattern matching in function heads**: The base case `count_paths_memo(_graph, target, target, memo)` elegantly handles reaching the destination
- **Memoization with map threading**: Passing and updating the memo map through reduce accumulator
- **Pipeline composition**: Clean data flow from input parsing to solution

### What Went Well

- Recognized immediately this was a DAG path counting problem
- The Part 2 decomposition into segments came naturally from the multiplication principle

### What Was Challenging

- Part 2's "visit both nodes in any order" initially seemed like it might require more complex state tracking, but the segment decomposition simplified it greatly

### Potential Improvements

- Could use ETS or process dictionary for memoization to avoid threading state through reduce
- Could precompute a topological sort for even more efficient path counting

---

## Related Concepts

- [DAG Path Counting](https://en.wikipedia.org/wiki/Directed_acyclic_graph)
- [Dynamic Programming on DAGs](https://www.geeksforgeeks.org/count-paths-source-destination-graph/)
- [Elixir Memoization Patterns](https://elixir-lang.org/getting-started/processes.html)
