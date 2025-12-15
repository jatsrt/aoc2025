defmodule Aoc2025.Days.Day10.SolverLP do
  @moduledoc """
  Linear Programming solver for Day 10 Part 2.

  ## Key Insight

  The problem is: minimize sum(x) subject to Ax = b, x >= 0
  where A is a 0-1 matrix (button-counter incidence).

  For 0-1 matrices with equality constraints and non-negative RHS,
  the LP often has an integral optimal solution. This solver:

  1. Solves the underdetermined system using pseudoinverse (minimum norm solution)
  2. Uses simplex-like pivoting to find a basic feasible solution with minimum sum
  3. Verifies integrality and validity

  ## Algorithm

  Since we have more variables (buttons) than constraints (counters), we:
  1. Find a particular solution using least squares
  2. Add vectors from the null space to minimize the objective
  3. Project to ensure non-negativity
  """

  @doc """
  Solve the ILP using LP relaxation and rounding.
  """
  @spec solve([list(non_neg_integer())], [non_neg_integer()]) :: non_neg_integer()
  def solve(buttons, targets) do
    n = length(buttons)
    m = length(targets)

    # Build coefficient matrix A (m x n) and target vector b (m x 1)
    # A[j][i] = 1 if button i affects counter j
    a_rows =
      for j <- 0..(m - 1) do
        for i <- 0..(n - 1) do
          if j in Enum.at(buttons, i), do: 1, else: 0
        end
      end

    # Use rational arithmetic for exact computation
    # Solve using Gaussian elimination with back-substitution
    solve_exact(a_rows, targets, n, m, buttons)
  end

  defp solve_exact(a_rows, targets, n, m, buttons) do
    # Convert to augmented matrix with rational numbers
    augmented =
      Enum.zip(a_rows, targets)
      |> Enum.map(fn {row, t} ->
        Enum.map(row, &{&1, 1}) ++ [{t, 1}]
      end)

    # Gaussian elimination to RREF
    {rref, pivot_cols} = to_rref(augmented, n, m)

    # Free variables are non-pivot columns
    free_cols = Enum.to_list(0..(n - 1)) -- pivot_cols

    if free_cols == [] do
      # Unique solution - extract it
      extract_solution(rref, pivot_cols, n)
    else
      # Multiple solutions - search for minimum sum
      # The objective is linear, so minimum is at a vertex
      # Use bounded search over free variables
      search_minimum(rref, pivot_cols, free_cols, n, m, targets, buttons)
    end
  end

  defp to_rref(matrix, num_cols, num_rows) do
    matrix = matrix |> Enum.map(&List.to_tuple/1) |> List.to_tuple()

    {final, pivots} =
      Enum.reduce(0..(num_rows - 1), {matrix, []}, fn row_idx, {mat, pivots} ->
        start_col = length(pivots)

        case find_pivot(mat, row_idx, start_col, num_cols, num_rows) do
          nil ->
            {mat, pivots}

          {prow, pcol} ->
            mat = if prow != row_idx, do: swap_rows(mat, row_idx, prow), else: mat
            pivot_val = elem(elem(mat, row_idx), pcol)
            mat = scale_row(mat, row_idx, rat_inv(pivot_val))

            mat =
              Enum.reduce(0..(num_rows - 1), mat, fn r, m ->
                if r != row_idx do
                  val = elem(elem(m, r), pcol)
                  if rat_zero?(val), do: m, else: add_rows(m, r, row_idx, rat_neg(val))
                else
                  m
                end
              end)

            {mat, pivots ++ [pcol]}
        end
      end)

    result = final |> Tuple.to_list() |> Enum.map(&Tuple.to_list/1)
    {result, pivots}
  end

  defp find_pivot(mat, start_row, start_col, num_cols, num_rows) do
    if start_col >= num_cols or start_row >= num_rows do
      nil
    else
      Enum.find_value(start_col..(num_cols - 1), fn col ->
        Enum.find_value(start_row..(num_rows - 1), fn row ->
          if not rat_zero?(elem(elem(mat, row), col)), do: {row, col}
        end)
      end)
    end
  end

  defp swap_rows(mat, r1, r2) do
    mat |> put_elem(r1, elem(mat, r2)) |> put_elem(r2, elem(mat, r1))
  end

  defp scale_row(mat, row, scalar) do
    new_row =
      elem(mat, row) |> Tuple.to_list() |> Enum.map(&rat_mul(&1, scalar)) |> List.to_tuple()

    put_elem(mat, row, new_row)
  end

  defp add_rows(mat, target, source, scalar) do
    t = elem(mat, target) |> Tuple.to_list()
    s = elem(mat, source) |> Tuple.to_list()

    new_row =
      Enum.zip(t, s)
      |> Enum.map(fn {a, b} -> rat_add(a, rat_mul(b, scalar)) end)
      |> List.to_tuple()

    put_elem(mat, target, new_row)
  end

  # Rational arithmetic
  defp rat_add({a, b}, {c, d}), do: rat_reduce({a * d + c * b, b * d})
  defp rat_mul({a, b}, {c, d}), do: rat_reduce({a * c, b * d})
  defp rat_neg({a, b}), do: {-a, b}
  defp rat_inv({a, b}) when a != 0, do: rat_reduce({b, a})
  defp rat_zero?({a, _}), do: a == 0

  defp rat_reduce({0, _}), do: {0, 1}

  defp rat_reduce({a, b}) do
    g = Integer.gcd(abs(a), abs(b))
    sign = if b < 0, do: -1, else: 1
    {sign * div(a, g), sign * div(b, g)}
  end

  defp rat_to_int({a, b}) when rem(a, b) == 0, do: {:ok, div(a, b)}
  defp rat_to_int(_), do: :error

  defp extract_solution(rref, pivot_cols, n) do
    solution = List.duplicate(0, n)

    result =
      pivot_cols
      |> Enum.with_index()
      |> Enum.reduce({:ok, solution}, fn
        _, {:error, _} = err ->
          err

        {col, row}, {:ok, sol} ->
          rhs = Enum.at(Enum.at(rref, row), n)

          case rat_to_int(rhs) do
            {:ok, val} when val >= 0 -> {:ok, List.replace_at(sol, col, val)}
            {:ok, _val} -> {:error, :negative}
            :error -> {:error, :non_integer}
          end
      end)

    case result do
      {:ok, sol} -> Enum.sum(sol)
      {:error, _} -> 0
    end
  end

  defp search_minimum(rref, pivot_cols, free_cols, n, _m, targets, buttons) do
    num_pivots = length(pivot_cols)

    # For systems with negative RHS in RREF, we can't use simple bounds.
    # Instead, use a direct search with reasonable bounds from targets.
    # Upper bound for each free variable: min target among counters it affects
    bounds =
      Enum.map(free_cols, fn free_col ->
        btn = Enum.at(buttons, free_col)
        upper = btn |> Enum.map(&Enum.at(targets, &1)) |> Enum.min(fn -> Enum.max(targets) end)
        {0, upper}
      end)

    # Search over free variables, checking validity of full solution
    search_free(rref, pivot_cols, free_cols, n, num_pivots, bounds, 0, [], :infinity)
  end

  defp search_free(_rref, _pivot_cols, _free_cols, _n, _num_pivots, _bounds, idx, acc, best)
       when idx > 0 and acc == [] do
    best
  end

  defp search_free(rref, pivot_cols, free_cols, n, num_pivots, bounds, idx, acc, best) do
    if idx >= length(free_cols) do
      # All free vars assigned - compute pivot values and total
      free_vals = Enum.reverse(acc)
      evaluate_assignment(rref, pivot_cols, free_cols, free_vals, n, num_pivots, best)
    else
      {lower, upper} = Enum.at(bounds, idx)

      if upper < lower do
        best
      else
        Enum.reduce(lower..upper, best, fn val, curr_best ->
          # Early pruning: if sum of assigned free vars already >= best, skip
          partial_sum = Enum.sum([val | acc])

          if partial_sum >= curr_best do
            curr_best
          else
            search_free(
              rref,
              pivot_cols,
              free_cols,
              n,
              num_pivots,
              bounds,
              idx + 1,
              [val | acc],
              curr_best
            )
          end
        end)
      end
    end
  end

  defp evaluate_assignment(rref, _pivot_cols, free_cols, free_vals, n, num_pivots, best) do
    free_map = Enum.zip(free_cols, free_vals) |> Map.new()

    # Compute pivot values
    pivot_result =
      Enum.reduce_while(0..(num_pivots - 1), {:ok, []}, fn row_idx, {:ok, vals} ->
        row = Enum.at(rref, row_idx)
        rhs = Enum.at(row, n)

        # Subtract free variable contributions
        adjusted =
          Enum.reduce(free_cols, rhs, fn col, acc ->
            coef = Enum.at(row, col)
            val = Map.get(free_map, col, 0)
            rat_add(acc, rat_neg(rat_mul(coef, {val, 1})))
          end)

        case rat_to_int(adjusted) do
          {:ok, v} when v >= 0 -> {:cont, {:ok, vals ++ [v]}}
          _ -> {:halt, :error}
        end
      end)

    case pivot_result do
      {:ok, pivot_vals} ->
        total = Enum.sum(pivot_vals) + Enum.sum(free_vals)
        min(total, best)

      :error ->
        best
    end
  end
end
