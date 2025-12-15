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

| Day | Stars | Solution | Writeup | Cost |
|-----|-------|----------|---------|------|
| [1](https://adventofcode.com/2025/day/1) | ⭐⭐ | [day01.ex](lib/aoc2025/days/day01.ex) | [day01.md](solutions/day01.md) | - |
| [2](https://adventofcode.com/2025/day/2) | ⭐⭐ | [day02.ex](lib/aoc2025/days/day02.ex) | [day02.md](solutions/day02.md) | - |
| [3](https://adventofcode.com/2025/day/3) | ⭐⭐ | [day03.ex](lib/aoc2025/days/day03.ex) | [day03.md](solutions/day03.md) | - |
| [4](https://adventofcode.com/2025/day/4) | ⭐⭐ | [day04.ex](lib/aoc2025/days/day04.ex) | [day04.md](solutions/day04.md) | $1.87 |
| [5](https://adventofcode.com/2025/day/5) | ⭐⭐ | [day05.ex](lib/aoc2025/days/day05.ex) | [day05.md](solutions/day05.md) | $2.71 |
| [6](https://adventofcode.com/2025/day/6) | ⭐⭐ | [day06.ex](lib/aoc2025/days/day06.ex) | [day06.md](solutions/day06.md) | $1.52 |
| [7](https://adventofcode.com/2025/day/7) | ⭐⭐ | [day07.ex](lib/aoc2025/days/day07.ex) | [day07.md](solutions/day07.md) | $1.34 |
| [8](https://adventofcode.com/2025/day/8) | ⭐⭐ | [day08.ex](lib/aoc2025/days/day08.ex) | [day08.md](solutions/day08.md) | $2.14 |
| [9](https://adventofcode.com/2025/day/9) | ⭐⭐ | [day09.ex](lib/aoc2025/days/day09.ex) | [day09.md](solutions/day09.md) | $4.07 |
| [10](https://adventofcode.com/2025/day/10) | ⭐⭐ | [day10.ex](lib/aoc2025/days/day10.ex) | [day10.md](solutions/day10.md) | $13.10 |
| [11](https://adventofcode.com/2025/day/11) | ⭐⭐ | [day11.ex](lib/aoc2025/days/day11.ex) | [day11.md](solutions/day11.md) | $2.20 |
| [12](https://adventofcode.com/2025/day/12) | ⭐⭐ | [day12.ex](lib/aoc2025/days/day12.ex) | [day12.md](solutions/day12.md) | $5.50 |

**Total: 24 stars - Advent of Code 2025 Complete!**

## License

MIT
