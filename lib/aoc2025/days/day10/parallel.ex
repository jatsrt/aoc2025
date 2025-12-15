defmodule Aoc2025.Days.Day10.Parallel do
  @moduledoc """
  Parallel processing wrapper for Day 10 solvers.

  Uses `Task.async_stream` to process all machines concurrently,
  leveraging all available CPU cores for maximum throughput.

  ## Usage

      Parallel.solve_all(machines, &SolverConstraint.solve/2)

  ## Performance

  For 152 machines on an 8-core machine, this provides up to 8x speedup
  compared to sequential processing.
  """

  @doc """
  Solve all machines in parallel using the given solver function.

  ## Parameters
  - `machines`: List of `{target, buttons, joltage}` tuples
  - `solver_fn`: Function that takes `(buttons, joltage)` and returns press count

  ## Returns
  Total minimum presses across all machines.
  """
  @spec solve_all(
          [{list(boolean()), [list(non_neg_integer())], [non_neg_integer()]}],
          ([list(non_neg_integer())], [non_neg_integer()] -> non_neg_integer())
        ) :: non_neg_integer()
  def solve_all(machines, solver_fn) do
    machines
    |> Task.async_stream(
      fn {_target, buttons, joltage} -> solver_fn.(buttons, joltage) end,
      max_concurrency: System.schedulers_online(),
      timeout: :infinity,
      ordered: false
    )
    |> Enum.map(fn {:ok, result} -> result end)
    |> Enum.sum()
  end

  @doc """
  Solve all machines sequentially (for comparison/debugging).
  """
  @spec solve_all_sequential(
          [{list(boolean()), [list(non_neg_integer())], [non_neg_integer()]}],
          ([list(non_neg_integer())], [non_neg_integer()] -> non_neg_integer())
        ) :: non_neg_integer()
  def solve_all_sequential(machines, solver_fn) do
    machines
    |> Enum.map(fn {_target, buttons, joltage} -> solver_fn.(buttons, joltage) end)
    |> Enum.sum()
  end
end
