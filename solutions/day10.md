# Day 10: Factory

> [Link to puzzle](https://adventofcode.com/2025/day/10)

## Problem Summary

### Part 1

Configure factory machines by pressing buttons that **toggle** indicator lights. Each button toggles specific lights (XOR operation). Find the minimum number of button presses to achieve target light patterns across all machines.

Since pressing a button twice cancels out, this is a problem over GF(2) (binary field) - find the minimum subset of buttons that XOR to the target pattern.

### Part 2

Same machines, but now buttons **increment** joltage counters instead of toggling. Each button press adds 1 to the counters it affects. Find the minimum total button presses to reach exact joltage targets.

This transforms the problem from linear algebra over GF(2) to **Integer Linear Programming (ILP)** over non-negative integers.

---

## Solution Development

### Understanding the Problem

**Input Format:**
```
[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
```
- `[.##.]` - Indicator light diagram (4 lights, pattern for Part 1)
- `(3) (1,3) ...` - Button wiring (which counters each button affects)
- `{3,5,4,7}` - Joltage targets (4 counters with target values)

**Constraints (Part 2):**
- 151 machines in full input
- 4-13 buttons per machine
- 4-10 counters per machine
- Target values up to ~300

**Mathematical Formulation:**
```
Minimize: sum(x_i) for all buttons i
Subject to: For each counter j, sum(x_i where button i affects j) = target[j]
            x_i >= 0 (non-negative integers)
```

### Why This Was Hard for AI to Solve

This problem presented several challenges that led to multiple failed approaches:

#### 1. **Misidentification of Problem Structure**

Initial attempts treated this as a simple optimization problem. The AI tried:
- **Greedy heuristics** - Press the "most efficient" button repeatedly
- **Brute force enumeration** - Try all button press combinations

Both failed because:
- Greedy doesn't guarantee optimality (produced invalid solutions that didn't satisfy constraints)
- Brute force is exponential: with 13 buttons and targets up to 300, that's 300^13 combinations

#### 2. **Underestimating Problem Complexity**

ILP is **NP-hard** in general. The AI's initial instinct was that "small inputs mean fast solutions," but:
- 13 buttons × 300 max value = massive search space even for one machine
- "Simple" constraint propagation only works when counters have unique buttons
- Most machines (120+ of 151) had 5+ "free" buttons after constraint propagation

#### 3. **Bugs in Linear Algebra Implementation**

The Gaussian elimination approach was conceptually correct but had implementation bugs:
- **Negative RHS in RREF**: After row reduction, some rows had negative right-hand-side values (e.g., `x7 = -19 + (4/3)*x8 + (1/3)*x9`), which broke naive bounds computation
- **Integer division truncation**: Computing bounds with integer division lost precision
- **Interdependent constraints**: Bounds on one free variable depend on values chosen for others

#### 4. **False Confidence in "Working" Solutions**

The greedy solver returned answers quickly, creating false confidence:
- Greedy returned 105 for a machine where optimal was 114
- But 105 was an **invalid solution** - it didn't satisfy all constraints
- Without verification, this would have produced wrong answers

#### 5. **Context Limitations in Iterative Debugging**

Each debugging cycle consumed context, making it harder to:
- Remember all failed approaches
- Maintain coherent understanding of the mathematical structure
- Track which invariants were actually being preserved

### Approach

**Key Insights:**

1. **The system is typically overdetermined** - More counters (equations) than degrees of freedom
2. **Gaussian elimination reveals structure** - RREF identifies pivot variables (determined) vs free variables (search space)
3. **Free variables are bounded** - Can't press a button more times than the minimum target it affects
4. **Rational arithmetic avoids errors** - Represent coefficients as `{numerator, denominator}` pairs

**The Working Solution: LP with RREF**

1. Build coefficient matrix A where A[j][i] = 1 if button i affects counter j
2. Perform Gaussian elimination to Reduced Row Echelon Form using rational arithmetic
3. Identify pivot columns (determined variables) and free columns
4. Search over free variable values (typically only 2-4 free variables)
5. For each assignment, compute pivot values from RREF equations
6. Validate: all values must be non-negative integers
7. Track minimum total across all valid solutions

**Alternative Approaches Considered:**

- **Greedy**: Fast but not guaranteed correct (produces invalid solutions)
- **Constraint propagation + Branch & Bound**: Correct but too slow (300^n search space)
- **Nx matrix operations**: Floating-point errors and non-integral solutions
- **Direct ILP solver**: Would require external dependency, overkill for this structure

### Implementation

#### Parsing

```elixir
def parse_machine(line) do
  {parse_target(line), parse_buttons(line), parse_joltage(line)}
end

defp parse_buttons(line) do
  ~r/\(([0-9,]+)\)/
  |> Regex.scan(line)
  |> Enum.map(fn [_, indices] ->
    indices |> String.split(",") |> Enum.map(&String.to_integer/1)
  end)
end
```

Uses regex to extract button wiring `(0,2,3)` and joltage targets `{3,5,4}`.

#### Part 1 Solution

```elixir
def min_light_presses({target, buttons}) do
  target_mask = to_bitmask(target)
  button_masks = buttons |> Enum.map(&to_bitmask_from_indices/1)

  # Find minimum subset that XORs to target
  Enum.find_value(0..num_buttons, fn k ->
    find_subset_of_size(target_mask, button_masks, k)
  end)
end
```

**Complexity:** O(2^n) worst case, but n is small (4-13 buttons)

Uses bitmask representation and iterates subset sizes from 0 upward.

#### Part 2 Solution

```elixir
def solve(buttons, targets) do
  # Build augmented matrix with rational arithmetic
  augmented = build_augmented_matrix(buttons, targets)

  # Gaussian elimination to RREF
  {rref, pivot_cols} = to_rref(augmented, n, m)

  # Free variables = non-pivot columns
  free_cols = Enum.to_list(0..(n-1)) -- pivot_cols

  # Search over free variable values
  search_minimum(rref, pivot_cols, free_cols, n, m, targets, buttons)
end
```

**Complexity:** O(m²n) for RREF + O(T^f) for search where T = max target, f = free variables

The key is that f (free variables) is typically 2-4, making T^f tractable (~100² = 10,000).

#### Rational Arithmetic

```elixir
defp rat_add({a, b}, {c, d}), do: rat_reduce({a * d + c * b, b * d})
defp rat_mul({a, b}, {c, d}), do: rat_reduce({a * c, b * d})
defp rat_reduce({a, b}) do
  g = Integer.gcd(abs(a), abs(b))
  {div(a, g), div(b, g)}
end
```

Represents numbers as `{numerator, denominator}` to maintain exact arithmetic during row operations.

---

## Results

| Part | Example | Puzzle | Time |
|------|---------|--------|------|
| 1    | 7       | 401    | <1ms |
| 2    | 33      | 15017  | ~700ms |

---

## Lessons Learned

### Elixir Patterns Used

- **Rational arithmetic with tuples**: `{numerator, denominator}` for exact computation
- **Parallel processing**: `Task.async_stream` to solve all 151 machines concurrently
- **Pattern matching in recursion**: Multi-clause `search_free` for base case handling
- **Pipeline composition**: `input |> parse() |> Parallel.solve_all(&solver/2)`

### What Went Well

- Identifying the mathematical structure (ILP over non-negative integers)
- Using Gaussian elimination to reduce search space dramatically
- Rational arithmetic avoiding floating-point precision issues
- Parallel processing for speed (all machines independent)

### What Was Challenging

- **Debugging without visibility**: Hard to trace through RREF transformations mentally
- **Negative RHS handling**: RREF can produce equations like `x = -19 + ...` requiring careful bounds
- **Verification**: Ensuring solutions actually satisfy all constraints
- **Multiple false starts**: Greedy, constraint propagation, Nx all failed before RREF worked

### Why AI Models Struggle with This Problem

1. **Pattern matching vs. mathematical reasoning**: AI excels at recognizing patterns from training data, but ILP requires structured mathematical analysis

2. **Debugging compound errors**: When Gaussian elimination had bugs, the AI tried to fix symptoms rather than root causes

3. **Overconfidence in "working" code**: Quick results from greedy solver delayed recognition that solutions were invalid

4. **Context fragmentation**: Each debugging iteration consumed context, making it harder to maintain coherent problem understanding

5. **Lack of verification instincts**: AI didn't automatically verify that computed solutions satisfied original constraints

### Potential Improvements

- Add solution verification as a standard step in all solvers
- Use symbolic computation libraries for exact arithmetic
- Consider external ILP solver for truly complex cases (e.g., GLPK, CBC)

---

## Related Concepts

- [Integer Linear Programming](https://en.wikipedia.org/wiki/Integer_programming)
- [Gaussian Elimination](https://en.wikipedia.org/wiki/Gaussian_elimination)
- [Reduced Row Echelon Form](https://en.wikipedia.org/wiki/Row_echelon_form#Reduced_row_echelon_form)
- [GF(2) (Binary Field)](https://en.wikipedia.org/wiki/GF(2)) - For Part 1
- [Elixir Task.async_stream](https://hexdocs.pm/elixir/Task.html#async_stream/3) - Parallel processing

---

## File Structure

```
lib/aoc2025/days/
├── day10.ex                    # Main module (Part 1 + orchestration)
└── day10/
    ├── solver_lp.ex            # LP solver with RREF (primary, correct)
    ├── solver_constraint.ex    # Constraint propagation (correct but slow)
    ├── solver_nx.ex            # Nx matrix solver (fallback)
    ├── solver_greedy.ex        # Greedy heuristic (fast but incorrect)
    └── parallel.ex             # Parallel processing wrapper
```

The multiple solver implementations serve as educational comparison of different approaches.
