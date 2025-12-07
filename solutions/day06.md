# Day 6: Trash Compactor

> [Link to puzzle](https://adventofcode.com/2025/day/6)

## Problem Summary

### Part 1

Parse a math worksheet where problems are arranged in **columns**. Each problem has numbers stacked vertically with an operator (`+` or `*`) at the bottom. Problems are separated by columns of only spaces. Read numbers row-by-row within each problem group, apply the operator, and sum all results.

### Part 2

Same worksheet, but read using "cephalopod math": each **column** within a problem group is a single number (digits read top-to-bottom, most significant first), and columns are processed **right-to-left**.

---

## Solution Development

### Understanding the Problem

**Inputs:**
- A multi-line string with numbers and operators arranged in columns
- Numbers are right-aligned within their columns
- Operators (`+` or `*`) appear at the bottom of each problem group
- Problems are separated by columns containing only spaces

**Constraints:**
- Numbers can have varying digit counts (1-4 digits typically)
- Must handle proper column alignment and padding
- Part 2 completely reinterprets the same data

**Key observation:** The same input encodes different problems depending on reading direction. This is a clever puzzle design that tests flexible parsing.

### Approach

Both parts share a common column-grouping strategy:

1. **Normalize rows** - Pad all rows to equal length
2. **Transpose** - Convert rows to columns for easier vertical access
3. **Group by separator** - Split on all-space columns to isolate problems

The difference is in how we extract numbers from each group:

**Part 1 (Row-based reading):**
- Transpose the column group back to rows
- Read each row as one number (ignore leading/trailing spaces)
- Extract operator from the bottom row

**Part 2 (Column-based reading):**
- Each column in the group IS one number
- Collect non-space characters top-to-bottom
- Reverse the list of numbers (right-to-left order)

### Key Insights

1. **Transpose is the key operation** - Converting between row and column representations makes both parsing strategies simple.

2. **Spaces have dual meaning** - They're both alignment padding AND problem separators. The separator columns are entirely spaces; padding spaces appear mixed with digits.

3. **Right-to-left reading changes everything** - For Part 2, the digit positions completely change. What looked like "64, 23, 314" becomes "4, 431, 623".

### Implementation

#### Parsing (Shared Setup)

```elixir
def parse(input) do
  rows = input |> String.split("\n", trim: true)
  max_len = rows |> Enum.map(&String.length/1) |> Enum.max()

  padded_rows =
    rows
    |> Enum.map(&String.pad_trailing(&1, max_len))
    |> Enum.map(&String.graphemes/1)

  columns = transpose(padded_rows)

  columns
  |> group_by_separator()
  |> Enum.map(&parse_problem_group/1)
end
```

#### Part 1 - Row Reading

```elixir
defp parse_problem_group(columns) do
  rows = transpose(columns)
  operator_row = List.last(rows)
  number_rows = Enum.drop(rows, -1)

  operator = parse_operator(operator_row)
  numbers = number_rows |> Enum.map(&parse_number_row/1) |> Enum.reject(&is_nil/1)

  {operator, numbers}
end
```

**Complexity:** O(n) where n is total characters in input

#### Part 2 - Column Reading (Cephalopod Math)

```elixir
defp parse_cephalopod_group(columns) do
  operator = columns |> Enum.map(&List.last/1) |> Enum.find(&(&1 in ["*", "+"])) |> ...

  numbers =
    columns
    |> Enum.map(fn col ->
      col |> Enum.drop(-1) |> Enum.reject(&(&1 == " ")) |> Enum.join()
    end)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&String.to_integer/1)
    |> Enum.reverse()  # Right-to-left!

  {operator, numbers}
end
```

**Complexity:** O(n) where n is total characters in input

---

## Results

| Part | Example | Puzzle | Time |
|------|---------|--------|------|
| 1    | ✓ 4,277,556 | 3,785,892,992,137 | <1ms |
| 2    | ✓ 3,263,827 | 7,669,802,156,452 | <1ms |

---

## Lessons Learned

### Elixir Patterns Used

- **`transpose/1`** - Recursive list-of-lists transposition using `hd/tl` pattern
- **`Enum.chunk_by/2`** - Perfect for grouping elements by a separator predicate
- **`Enum.product/1`** - Built-in multiplication reduction (like `Enum.sum/1`)
- **Pattern matching in `case`** - Clean operator dispatch with `{:add, nums}` tuples

### What Went Well

- The transpose operation made both parsing strategies straightforward
- Separating parsing from solving kept the code modular
- The shared column-grouping logic avoided duplication between parts

### What Was Challenging

- Understanding the cephalopod reading direction took careful example analysis
- Ensuring spaces were handled correctly in both contexts (separator vs padding)

### Potential Improvements

- Could refactor to share more code between `parse/1` and `parse_cephalopod/1`
- The transpose function could use `Enum.zip_with/2` for a more idiomatic approach:
  ```elixir
  defp transpose(rows), do: rows |> Enum.zip_with(&Function.identity/1)
  ```

---

## Related Concepts

- [Matrix transposition](https://en.wikipedia.org/wiki/Transpose) - The core operation enabling column-based parsing
- [Right-to-left scripts](https://en.wikipedia.org/wiki/Right-to-left_script) - Real-world parallel to cephalopod math!
- Elixir's [`Enum.chunk_by/2`](https://hexdocs.pm/elixir/Enum.html#chunk_by/2) - Essential for splitting by separators
