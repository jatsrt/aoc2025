# Advent of Code 2025 - Elixir Solutions

Solutions to [Advent of Code 2025](https://adventofcode.com/2025) implemented in Elixir, with a focus on educational value and thorough documentation.

## Goals

- **Learn Elixir**: Use AoC as an opportunity to explore Elixir's functional patterns
- **Document Everything**: Each solution includes detailed reasoning and explanations
- **Test First**: Verify solutions with example data before attempting full inputs
- **Share Knowledge**: Make solutions accessible to others learning Elixir or algorithms

## Quick Start

```bash
# Install dependencies
mix deps.get

# Run a specific day
mix day 1

# Run with example input (for testing)
mix example 1

# Run tests for a specific day
mix test.day 1

# Run all example tests
mix test

# Run all tests including full puzzle inputs
mix test --include solution
```

## Project Structure

```
lib/
  aoc2025.ex              # Main module
  aoc2025/
    day.ex                # Behaviour and helpers for solutions
    input.ex              # Input loading utilities
    days/                 # Daily solutions
      day01.ex
      day02.ex
      ...

priv/
  inputs/                 # Full puzzle inputs
    day01.txt
    examples/             # Example inputs from problem descriptions
      day01.txt

solutions/                # Detailed solution writeups
  day01.md
  day02.md
  ...

test/
  days/                   # Tests for each day
    day01_test.exs
```

## Solution Format

Each day includes:

1. **Solution Module** (`lib/aoc2025/days/dayXX.ex`)
   - Implements `part1/1` and `part2/1`
   - Includes parsing logic and helper functions
   - Documented with `@moduledoc` and `@doc`

2. **Tests** (`test/days/dayXX_test.exs`)
   - Verifies example inputs match expected outputs
   - Tests full puzzle inputs (tagged `:solution`)

3. **Writeup** (`solutions/dayXX.md`)
   - Problem summary
   - Solution approach and reasoning
   - Complexity analysis
   - Lessons learned

## Adding a New Day

Templates are provided in:
- `lib/aoc2025/days/.day_template.ex`
- `test/days/.day_template_test.exs`
- `solutions/.day_template.md`

1. Copy templates and rename (e.g., `day01.ex`)
2. Add input files to `priv/inputs/` and `priv/inputs/examples/`
3. Implement the solution
4. Document your approach

## Progress

| Day | Stars | Solution | Writeup |
|-----|-------|----------|---------|
| 1   |       |          |         |
| 2   |       |          |         |
| ... |       |          |         |

## License

MIT
