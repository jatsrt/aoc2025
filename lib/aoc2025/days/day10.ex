defmodule Aoc2025.Days.Day10 do
  @moduledoc """
  # Day 10: Factory

  Configure factory machines by pressing buttons to toggle indicator lights
  or increment joltage counters.

  ## Part 1 - Indicator Lights (XOR/Toggle)

  Find the minimum total button presses needed to configure all machines
  so their indicator lights match the target patterns. Since pressing a
  button twice cancels out, each button is pressed 0 or 1 times.

  ## Part 2 - Joltage Counters (Addition)

  Find the minimum total button presses to reach exact joltage targets.
  Each button press adds 1 to certain counters. This is an Integer Linear
  Programming (ILP) problem solved using Gaussian elimination to RREF.

  ### Available Solvers (in `Day10.*` submodules)

  1. **SolverLP** - Gaussian elimination to RREF with search (default, fast and correct)
  2. **SolverConstraint** - Constraint propagation + branch & bound (correct but slow)
  3. **SolverNx** - Nx matrix operations with fallback
  4. **SolverGreedy** - Greedy heuristic (fast but not guaranteed correct)
  5. **Parallel** - Wrapper for parallel processing of machines

  ## Key Insight

  Part 1 is linear algebra over GF(2) (binary field) - XOR operations.
  Part 2 is linear algebra over integers with non-negativity constraints.
  Using RREF reduces the search space from O(T^n) to O(T^f) where f = free variables.
  """

  use Aoc2025.Day
  import Bitwise

  alias Aoc2025.Days.Day10.{Parallel, SolverConstraint, SolverLP}

  # Types
  @typedoc "Target light pattern as a list of booleans (true = on)"
  @type target :: [boolean()]

  @typedoc "Button configuration - list of counter indices it affects"
  @type button :: [non_neg_integer()]

  @typedoc "Joltage requirements - list of target values for each counter"
  @type joltage :: [non_neg_integer()]

  @typedoc "A single machine with its target pattern, buttons, and joltage"
  @type machine :: {target(), [button()], joltage()}

  @doc """
  Solve Part 1: Find minimum button presses to configure all machines' lights.
  """
  @impl true
  @spec part1(String.t()) :: non_neg_integer()
  def part1(input) do
    input
    |> parse()
    |> Enum.map(fn {target, buttons, _joltage} -> min_light_presses({target, buttons}) end)
    |> Enum.sum()
  end

  @doc """
  Solve Part 2: Find minimum button presses to configure all machines' joltage.

  Uses parallel processing with LP-based solver that uses Gaussian elimination
  to RREF and searches over free variables.
  """
  @impl true
  @spec part2(String.t()) :: non_neg_integer()
  def part2(input) do
    input
    |> parse()
    |> Parallel.solve_all(&SolverLP.solve/2)
  end

  @doc """
  Solve Part 2 with a specific solver (for benchmarking/comparison).

  ## Solvers
  - `:lp` - LP-based solver with RREF (default, fast and correct)
  - `:constraint` - Constraint propagation + branch & bound (slow)
  - `:nx` - Nx matrix solution with fallback
  - `:gauss` - Gaussian elimination with fallback (legacy)
  """
  @spec part2_with_solver(String.t(), atom()) :: non_neg_integer()
  def part2_with_solver(input, solver) do
    solver_fn = get_solver(solver)

    input
    |> parse()
    |> Parallel.solve_all(solver_fn)
  end

  defp get_solver(:lp), do: &SolverLP.solve/2
  defp get_solver(:constraint), do: &SolverConstraint.solve/2
  defp get_solver(:nx), do: &Aoc2025.Days.Day10.SolverNx.solve/2
  defp get_solver(:gauss), do: &min_joltage_presses/2
  defp get_solver(_), do: &SolverLP.solve/2

  @doc """
  Parse the input into machine specifications.

  ## Input Format

  Each line contains:
  - `[.##.]` - indicator light diagram (. = off, # = on)
  - `(0,2,3)` - button wiring schematics (which counters affected)
  - `{3,5,4}` - joltage requirements

  ## Output Format

  List of `{target, buttons, joltage}` tuples where:
  - `target` is a list of booleans for the desired light state
  - `buttons` is a list of buttons, each a list of counter indices
  - `joltage` is a list of target counter values
  """
  @impl true
  @spec parse(String.t()) :: [machine()]
  def parse(input), do: input |> lines() |> Enum.map(&parse_machine/1)

  @doc """
  Parse a single machine line into {target, buttons, joltage}.
  """
  @spec parse_machine(String.t()) :: machine()
  def parse_machine(line) do
    {parse_target(line), parse_buttons(line), parse_joltage(line)}
  end

  defp parse_target(line) do
    ~r/\[([.#]+)\]/
    |> Regex.run(line)
    |> List.last()
    |> String.graphemes()
    |> Enum.map(&(&1 == "#"))
  end

  defp parse_buttons(line) do
    ~r/\(([0-9,]+)\)/
    |> Regex.scan(line)
    |> Enum.map(fn [_, indices] ->
      indices |> String.split(",") |> Enum.map(&String.to_integer/1)
    end)
  end

  defp parse_joltage(line) do
    ~r/\{([0-9,]+)\}/
    |> Regex.run(line)
    |> List.last()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  # --- Part 1 Implementation (XOR/Toggle) ---

  @doc """
  Find the minimum number of button presses to achieve the target light pattern.

  Since toggling is XOR-based, pressing a button twice cancels out.
  We need to find the minimum subset of buttons that XOR to the target.
  """
  @spec min_light_presses({target(), [button()]}) :: non_neg_integer()
  def min_light_presses({target, buttons}) do
    num_lights = length(target)
    num_buttons = length(buttons)

    # Convert target to bitmask
    target_mask = to_bitmask(target)

    # Convert each button to a bitmask of which lights it toggles
    button_masks =
      buttons
      |> Enum.map(fn indices ->
        Enum.reduce(indices, 0, fn idx, acc -> acc ||| 1 <<< idx end)
      end)
      |> List.to_tuple()

    # Find minimum subset of buttons that XOR to target
    find_min_subset(target_mask, button_masks, num_buttons, num_lights)
  end

  defp to_bitmask(booleans) do
    booleans
    |> Enum.with_index()
    |> Enum.reduce(0, fn {val, idx}, acc ->
      if val, do: acc ||| 1 <<< idx, else: acc
    end)
  end

  defp find_min_subset(target_mask, button_masks, num_buttons, _num_lights) do
    # Try subsets in order of increasing size
    # For each size k, try all combinations of k buttons
    Enum.find_value(0..num_buttons, fn k ->
      find_subset_of_size(target_mask, button_masks, num_buttons, k)
    end)
  end

  defp find_subset_of_size(target_mask, button_masks, num_buttons, k) do
    # Generate all combinations of k buttons and check if any XORs to target
    combinations(num_buttons, k)
    |> Enum.find_value(fn combo ->
      result = Enum.reduce(combo, 0, fn idx, acc -> bxor(acc, elem(button_masks, idx)) end)
      if result == target_mask, do: k, else: nil
    end)
  end

  # Generate all combinations of k elements from 0..n-1
  defp combinations(n, k) when k > n, do: []
  defp combinations(_n, 0), do: [[]]

  defp combinations(n, k) do
    for i <- 0..(n - k), rest <- combinations_from(i + 1, n, k - 1), do: [i | rest]
  end

  defp combinations_from(start, n, 0) when start <= n, do: [[]]
  defp combinations_from(start, n, _k) when start >= n, do: []

  defp combinations_from(start, n, k) do
    for i <- start..(n - k), rest <- combinations_from(i + 1, n, k - 1), do: [i | rest]
  end

  # --- Part 2 Implementation (Addition/ILP) ---

  @doc """
  Find the minimum number of button presses to reach exact joltage targets.

  This is an Integer Linear Programming problem: find non-negative integers
  x_i (presses for button i) such that for each counter j, the sum of x_i
  where button i affects counter j equals target[j], minimizing sum(x_i).

  Uses Gaussian elimination to reduce the system, then searches over free variables.
  """
  @spec min_joltage_presses([button()], joltage()) :: non_neg_integer()
  def min_joltage_presses(buttons, targets) do
    result = gauss_solve(buttons, targets)

    # Fall back to constraint solver if Gaussian method fails
    if result == :infinity do
      SolverConstraint.solve(buttons, targets)
    else
      result
    end
  end

  defp gauss_solve(buttons, targets) do
    n = length(buttons)
    m = length(targets)

    # Build augmented matrix [A | b] using rational arithmetic {num, den}
    # A[j][i] = 1 if button i affects counter j
    matrix =
      for j <- 0..(m - 1) do
        row =
          for i <- 0..(n - 1) do
            if j in Enum.at(buttons, i), do: {1, 1}, else: {0, 1}
          end

        row ++ [{Enum.at(targets, j), 1}]
      end

    # Gaussian elimination to reduced row echelon form
    {rref, pivot_cols} = gaussian_eliminate(matrix, n)

    # Extract solution using back-substitution with free variables
    free_cols = Enum.to_list(0..(n - 1)) -- pivot_cols

    # Search over free variable assignments
    find_min_solution(rref, pivot_cols, free_cols, n, m, targets)
  end

  # Gaussian elimination to RREF, tracking pivot columns
  defp gaussian_eliminate(matrix, num_cols) do
    num_rows = length(matrix)
    matrix = List.to_tuple(Enum.map(matrix, &List.to_tuple/1))

    {final_matrix, pivot_cols} =
      Enum.reduce(0..(num_rows - 1), {matrix, []}, fn row_idx, {mat, pivots} ->
        # Find pivot column (first non-zero in remaining columns)
        start_col = length(pivots)

        case find_pivot(mat, row_idx, start_col, num_cols, num_rows) do
          nil ->
            {mat, pivots}

          {pivot_row, pivot_col} ->
            # Swap rows if needed
            mat =
              if pivot_row != row_idx do
                swap_rows(mat, row_idx, pivot_row)
              else
                mat
              end

            # Scale pivot row to make pivot = 1
            pivot_val = elem(elem(mat, row_idx), pivot_col)
            mat = scale_row(mat, row_idx, rat_inv(pivot_val))

            # Eliminate column in all other rows
            mat =
              Enum.reduce(0..(num_rows - 1), mat, fn r, m ->
                if r != row_idx do
                  val = elem(elem(m, r), pivot_col)

                  if rat_is_zero?(val) do
                    m
                  else
                    add_scaled_row(m, r, row_idx, rat_neg(val))
                  end
                else
                  m
                end
              end)

            {mat, pivots ++ [pivot_col]}
        end
      end)

    # Convert back to list format
    result =
      final_matrix
      |> Tuple.to_list()
      |> Enum.map(&Tuple.to_list/1)

    {result, pivot_cols}
  end

  defp find_pivot(matrix, start_row, start_col, num_cols, num_rows) do
    if start_col >= num_cols or start_row >= num_rows do
      nil
    else
      Enum.find_value(start_col..(num_cols - 1), fn col ->
        Enum.find_value(start_row..(num_rows - 1), fn row ->
          val = elem(elem(matrix, row), col)
          if not rat_is_zero?(val), do: {row, col}
        end)
      end)
    end
  end

  defp swap_rows(matrix, r1, r2) do
    row1 = elem(matrix, r1)
    row2 = elem(matrix, r2)
    matrix |> put_elem(r1, row2) |> put_elem(r2, row1)
  end

  defp scale_row(matrix, row_idx, scalar) do
    row = elem(matrix, row_idx)

    new_row =
      row
      |> Tuple.to_list()
      |> Enum.map(&rat_mul(&1, scalar))
      |> List.to_tuple()

    put_elem(matrix, row_idx, new_row)
  end

  defp add_scaled_row(matrix, target_row, source_row, scalar) do
    t_row = elem(matrix, target_row)
    s_row = elem(matrix, source_row)

    new_row =
      Enum.zip(Tuple.to_list(t_row), Tuple.to_list(s_row))
      |> Enum.map(fn {t, s} -> rat_add(t, rat_mul(s, scalar)) end)
      |> List.to_tuple()

    put_elem(matrix, target_row, new_row)
  end

  # Rational arithmetic helpers
  defp rat_add({a, b}, {c, d}), do: rat_reduce({a * d + c * b, b * d})
  defp rat_mul({a, b}, {c, d}), do: rat_reduce({a * c, b * d})
  defp rat_neg({a, b}), do: {-a, b}
  defp rat_inv({a, b}), do: rat_reduce({b, a})
  defp rat_is_zero?({a, _}), do: a == 0

  defp rat_reduce({0, _}), do: {0, 1}

  defp rat_reduce({a, b}) do
    g = Integer.gcd(abs(a), abs(b))
    sign = if b < 0, do: -1, else: 1
    {sign * div(a, g), sign * div(b, g)}
  end

  defp rat_to_int({a, b}) when rem(a, b) == 0, do: {:ok, div(a, b)}
  defp rat_to_int(_), do: :error

  # Find minimum solution by searching over free variables
  defp find_min_solution(rref, pivot_cols, free_cols, n, _m, targets) do
    num_pivots = length(pivot_cols)

    # If no free variables, just check the unique solution
    if free_cols == [] do
      solution = extract_unique_solution(rref, pivot_cols, n)
      if valid_solution?(solution), do: Enum.sum(solution), else: 0
    else
      # Compute tighter upper bounds for each free variable
      # Based on the non-negativity constraints of pivot variables
      max_target = Enum.max(targets)

      # Search over free variable assignments with iterative deepening
      search_free_vars_iterative(rref, pivot_cols, free_cols, n, num_pivots, max_target)
    end
  end

  defp extract_unique_solution(rref, pivot_cols, n) do
    # Initialize solution with zeros
    solution = List.duplicate(0, n)

    # For each pivot row, the pivot variable equals the RHS
    pivot_cols
    |> Enum.with_index()
    |> Enum.reduce(solution, fn {col, row_idx}, sol ->
      rhs = Enum.at(Enum.at(rref, row_idx), n)

      case rat_to_int(rhs) do
        {:ok, val} -> List.replace_at(sol, col, val)
        :error -> List.replace_at(sol, col, -1)
      end
    end)
  end

  # Search by enumerating free variable combinations and finding minimum total
  defp search_free_vars_iterative(rref, pivot_cols, free_cols, n, num_pivots, max_val) do
    num_free = length(free_cols)

    # Compute bounds for free variables based on RREF constraints
    # Each pivot variable must be >= 0, which constrains free variables
    bounds = compute_free_bounds(rref, pivot_cols, free_cols, n, num_pivots, max_val)

    # Search over all valid combinations
    search_min(rref, pivot_cols, free_cols, n, num_pivots, bounds, num_free, [], :infinity)
  end

  # Compute bounds for each free variable (both lower and upper)
  # Returns list of {lower_bound, upper_bound} tuples
  defp compute_free_bounds(rref, _pivot_cols, free_cols, n, num_pivots, max_val) do
    # For each free variable, find bounds that keep all pivots >= 0
    # pivot_i = rhs_i - sum_j(coef_ij * free_j) >= 0
    # For a single free var: pivot = rhs - coef * free >= 0
    # If coef > 0: free <= rhs / coef (upper bound)
    # If coef < 0: free >= rhs / coef (lower bound, but rhs/coef is negative)
    Enum.map(free_cols, fn col ->
      {lower, upper} =
        Enum.reduce(0..(num_pivots - 1), {0, max_val}, fn row_idx, {lo, hi} ->
          row = Enum.at(rref, row_idx)
          {coef_num, coef_den} = Enum.at(row, col)
          {rhs_num, rhs_den} = Enum.at(row, n)

          cond do
            coef_num > 0 ->
              # free <= rhs / coef
              max_free = div(rhs_num * coef_den, rhs_den * coef_num)
              {lo, min(hi, max_free)}

            coef_num < 0 ->
              # free >= rhs / coef (but coef < 0, so this flips)
              # rhs - coef * free >= 0 => -coef * free >= -rhs => free >= rhs/coef
              # Since coef < 0, rhs/coef could be negative (meaning no lower bound from x>=0)
              min_free = div(rhs_num * coef_den, rhs_den * coef_num)
              # If min_free is negative, keep lower bound at 0
              {max(lo, min_free), hi}

            true ->
              {lo, hi}
          end
        end)

      # Ensure valid range
      {max(0, lower), max(0, upper)}
    end)
  end

  # Recursive search over free variables, minimizing total
  defp search_min(rref, pivot_cols, free_cols, n, num_pivots, bounds, remaining, acc, best) do
    if remaining == 0 do
      # All free vars assigned, evaluate
      free_vals = Enum.reverse(acc)

      case try_assignment_result(rref, pivot_cols, free_cols, free_vals, n, num_pivots) do
        {:ok, total} -> min(total, best)
        :error -> best
      end
    else
      idx = length(acc)
      {lower, upper} = Enum.at(bounds, idx)

      # Skip if invalid range (upper < lower means no solution)
      if upper < lower do
        best
      else
        Enum.reduce(lower..upper, best, fn val, current_best ->
          new_acc = [val | acc]

          search_min(
            rref,
            pivot_cols,
            free_cols,
            n,
            num_pivots,
            bounds,
            remaining - 1,
            new_acc,
            current_best
          )
        end)
      end
    end
  end

  defp try_assignment_result(rref, pivot_cols, free_cols, free_vals, n, num_pivots) do
    # Build free variable map
    free_map = Enum.zip(free_cols, free_vals) |> Map.new()

    # Compute pivot variables from RREF
    pivot_vals =
      Enum.map(0..(num_pivots - 1), fn row_idx ->
        row = Enum.at(rref, row_idx)
        rhs = Enum.at(row, n)

        # Subtract contributions from free variables
        adjusted_rhs =
          Enum.reduce(free_cols, rhs, fn col, acc ->
            coef = Enum.at(row, col)
            val = Map.get(free_map, col, 0)
            rat_add(acc, rat_neg(rat_mul(coef, {val, 1})))
          end)

        rat_to_int(adjusted_rhs)
      end)

    # Check if all pivot values are valid non-negative integers
    if Enum.all?(pivot_vals, fn
         {:ok, v} -> v >= 0
         :error -> false
       end) do
      pivot_int_vals = Enum.map(pivot_vals, fn {:ok, v} -> v end)

      # Build full solution
      solution = List.duplicate(0, n)

      solution =
        Enum.zip(pivot_cols, pivot_int_vals)
        |> Enum.reduce(solution, fn {col, val}, sol ->
          List.replace_at(sol, col, val)
        end)

      solution =
        Enum.zip(free_cols, free_vals)
        |> Enum.reduce(solution, fn {col, val}, sol ->
          List.replace_at(sol, col, val)
        end)

      {:ok, Enum.sum(solution)}
    else
      :error
    end
  end

  defp valid_solution?(solution), do: Enum.all?(solution, &(&1 >= 0))
end
