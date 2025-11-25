# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Model Requirement

**This project requires Claude Opus 4.5** (`claude-opus-4-5-20250929` or equivalent). The educational focus and detailed reasoning documentation benefit from Opus's stronger analytical and explanatory capabilities. Do not use Sonnet or Haiku for solving puzzles.

## Project Overview

This is an Advent of Code 2025 solutions repository in Elixir. The primary goal is **educational** - solutions should be well-documented so others can learn from the problem-solving process, Elixir patterns, and algorithmic approaches.

## Commands

```bash
# Install dependencies
mix deps.get

# Run a specific day's solution
mix day 1

# Run with example input
mix example 1

# Run tests for a specific day
mix test.day 1

# Run all example tests (fast - excludes full puzzle solutions)
mix test

# Run all tests including full solutions
mix test --include solution

# Format code
mix format

# Generate documentation
mix docs
```

## Architecture

### Module Structure

- `Aoc2025.Day` - Behaviour that all solutions implement; provides helpers via `use Aoc2025.Day`
- `Aoc2025.Day.Helpers` - Common parsing utilities: `lines/1`, `integers/1`, `paragraphs/1`, `grid/1`, `extract_integers/1`
- `Aoc2025.Input` - Loads inputs from `priv/inputs/` directory
- `Aoc2025.Days.DayXX` - Individual day solutions

### File Locations

| Purpose | Location |
|---------|----------|
| Solution code | `lib/aoc2025/days/dayXX.ex` |
| Full puzzle input | `priv/inputs/dayXX.txt` |
| Example input | `priv/inputs/examples/dayXX.txt` |
| Tests | `test/days/dayXX_test.exs` |
| Solution writeup | `solutions/dayXX.md` |
| Templates | Files prefixed with `.day_template` |

## Solving a New Day

### Step 1: Setup Files

1. Copy templates:
   - `lib/aoc2025/days/.day_template.ex` → `lib/aoc2025/days/dayXX.ex`
   - `test/days/.day_template_test.exs` → `test/days/dayXX_test.exs`
   - `solutions/.day_template.md` → `solutions/dayXX.md`

2. Create input files:
   - `priv/inputs/dayXX.txt` - Full puzzle input
   - `priv/inputs/examples/dayXX.txt` - Example from problem description

3. Update module names and day numbers in copied files

### Step 2: Understand the Problem

Before writing code:

1. **Read the entire problem** carefully - both parts if visible
2. **Identify the input format** - structure, delimiters, edge cases
3. **Extract the example** - note expected outputs for validation
4. **Identify constraints** - size of input, time/space requirements
5. **Document your understanding** in the solution writeup

### Step 3: Solve with Tests

**Always verify with example data first:**

```bash
# Run just example tests during development
mix test.day XX

# Only run full solution tests after examples pass
mix test.day XX --include solution
```

### Step 4: Document Thoroughly

The solution writeup (`solutions/dayXX.md`) must include:

1. **Problem Summary** - Your understanding in plain language
2. **Approach** - Why you chose this approach, alternatives considered
3. **Key Insights** - The "aha" moments that made the solution work
4. **Implementation Notes** - Tricky parsing, edge cases handled
5. **Complexity Analysis** - Time and space complexity with explanation
6. **Lessons Learned** - Elixir patterns, algorithms, or concepts learned

## Educational Standards

### Code Quality

- Use descriptive function names that explain intent
- Add `@doc` strings explaining what each public function does
- Use `@moduledoc` to provide a high-level overview
- Prefer clarity over cleverness - readable code teaches better
- Use pipeline operator `|>` idiomatically for data transformations

### Documentation Quality

Each solution should answer:

- "What is this problem really asking?"
- "Why does this approach work?"
- "What Elixir features make this elegant?"
- "What would I do differently next time?"

### Testing

- Test parsing separately from solving
- Include edge cases identified in analysis
- Example tests run by default; full solution tests are tagged `:solution`

## Common Patterns

### Parsing Helpers

```elixir
# Available via `use Aoc2025.Day`:
lines(input)           # Split into lines
integers(input)        # Lines as integers
paragraphs(input)      # Split on blank lines
grid(input)            # Map of {x,y} => char
extract_integers(str)  # All integers from string
```

### Solution Structure

```elixir
defmodule Aoc2025.Days.Day01 do
  use Aoc2025.Day

  @impl true
  def part1(input) do
    input |> parse() |> solve_part1()
  end

  @impl true
  def part2(input) do
    input |> parse() |> solve_part2()
  end

  def parse(input) do
    # Transform raw string into useful data structure
  end

  defp solve_part1(data), do: # ...
  defp solve_part2(data), do: # ...
end
```

## Problem-Solving Process

When Claude solves an AoC problem, follow this workflow:

### 1. Analysis Phase

- Read the problem statement completely
- Identify: inputs, outputs, constraints, examples
- Write the problem summary in the solution writeup
- Consider multiple approaches before implementing

### 2. Implementation Phase

- Start with parsing - get the data structure right
- Implement part 1, verify with example
- Implement part 2, verify with example
- Run full tests only after examples pass

### 3. Documentation Phase

- Complete the solution writeup
- Add complexity analysis
- Note interesting Elixir patterns used
- Record lessons learned

### 4. Verification Phase

- Run `mix test.day XX --include solution`
- Verify both parts produce correct answers
- Commit with meaningful message

## Commit Standards

When committing solutions:

```
Day XX: [Puzzle Title]

- Part 1: [brief approach description]
- Part 2: [brief approach description]
- Key insight: [what made it click]
```

## Functional Programming Philosophy

**This project showcases Elixir's functional strengths.** Solutions should be as functional as possible, demonstrating idiomatic patterns that highlight why Elixir excels at data transformation problems.

### Core Principles

1. **Immutability** - Never mutate; transform data through pipelines
2. **Pure Functions** - Same input always produces same output, no side effects
3. **Composition** - Build complex solutions from small, composable functions
4. **Declarative Style** - Describe *what* to compute, not *how* step-by-step

### Pipeline-First Design

Structure solutions as data transformation pipelines. The `|>` operator should be the backbone of every solution:

```elixir
# GOOD: Clear data flow through transformations
def part1(input) do
  input
  |> parse()
  |> find_valid_entries()
  |> calculate_scores()
  |> Enum.sum()
end

# AVOID: Nested function calls obscure the flow
def part1(input) do
  Enum.sum(calculate_scores(find_valid_entries(parse(input))))
end
```

### Advanced Features to Showcase

#### Pattern Matching Everywhere

```elixir
# In function heads - multiple clauses over conditionals
def process({:ok, value}), do: transform(value)
def process({:error, _}), do: :skip

# Destructuring in parameters
def handle_instruction({"move", amount}, position), do: ...
def handle_instruction({"turn", direction}, position), do: ...

# In comprehensions
for {:valid, x, y} <- entries, do: {x, y}
```

#### Guards for Expressiveness

```elixir
def categorize(n) when n < 0, do: :negative
def categorize(n) when n == 0, do: :zero
def categorize(n) when n > 0, do: :positive

# Custom guards for domain concepts
defguard is_valid_coord(x, y, max) when x >= 0 and x < max and y >= 0 and y < max
```

#### Recursion with Accumulators

```elixir
# Tail-recursive with accumulator for efficiency
def sum_list(list), do: sum_list(list, 0)
defp sum_list([], acc), do: acc
defp sum_list([h | t], acc), do: sum_list(t, acc + h)
```

#### Comprehensions for Clarity

```elixir
# Generators + filters + collection in one expression
for x <- 0..width,
    y <- 0..height,
    grid[{x, y}] == "#",
    neighbor <- neighbors({x, y}),
    Map.get(grid, neighbor) == ".",
    into: MapSet.new() do
  neighbor
end
```

#### Stream for Large/Infinite Data

```elixir
# Lazy evaluation - process only what's needed
input
|> String.splitter("\n", trim: true)
|> Stream.map(&parse_line/1)
|> Stream.filter(&valid?/1)
|> Enum.take(1000)

# Infinite sequences
Stream.iterate(initial_state, &step/1)
|> Stream.drop_while(&(not solved?(&1)))
|> Enum.take(1)
```

#### `with` for Sequential Operations

```elixir
# Chain operations that might fail, bail early on error
with {:ok, parsed} <- parse(input),
     {:ok, validated} <- validate(parsed),
     {:ok, result} <- compute(validated) do
  {:ok, result}
end
```

#### `Enum.reduce` as the Swiss Army Knife

```elixir
# Most AoC problems are reductions
instructions
|> Enum.reduce(initial_state, fn instruction, state ->
  apply_instruction(instruction, state)
end)
```

#### Map/MapSet for Performance

```elixir
# O(1) lookups instead of O(n) list searches
visited = MapSet.new()
grid = Map.new(coords, fn {x, y, val} -> {{x, y}, val} end)

# Update patterns
MapSet.put(visited, position)
Map.update(counts, key, 1, &(&1 + 1))
```

### Patterns to Demonstrate

| Pattern | When to Use | Example |
|---------|-------------|---------|
| Multi-clause functions | Different input shapes | `process/1` with pattern matching |
| Recursive descent | Tree/nested structures | Parsing nested brackets |
| State accumulation | Simulations, folding | `Enum.reduce` with state tuple |
| Graph traversal | Path finding, connectivity | BFS/DFS with MapSet visited |
| Memoization | Overlapping subproblems | Process dictionary or ETS |
| Coordinate maps | 2D/3D grids | `%{{x, y} => value}` |

### What to Avoid

- **Indexed loops** - Use `Enum.with_index/1` if indices needed
- **Mutable state** - Use `Enum.reduce/3` or recursion with accumulators
- **Imperative conditionals** - Prefer pattern matching and guards
- **Deeply nested code** - Extract to named helper functions
- **Early returns** - Structure with pattern matching instead

### Learning Highlights

In the solution writeup, explicitly call out:

- "This solution uses [pattern] because..."
- "The pipeline here transforms data through: parse → filter → map → reduce"
- "Using `Stream` here avoids materializing the full list because..."
- "The guard clause `when x > 0` is clearer than an `if` because..."
