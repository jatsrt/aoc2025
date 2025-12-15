defmodule Aoc2025.Days.Day10.SolverGreedy do
  @moduledoc """
  Greedy solver for Day 10 Part 2.

  ## Algorithm

  Repeatedly press the button that makes the most progress toward the goal
  until all targets are reached.

  ## Correctness

  NOT guaranteed optimal for all inputs, but works well for many AoC problems
  where the greedy choice happens to be optimal.

  ## Performance

  O(n * m * max_target) - very fast
  """

  @doc """
  Find minimum total button presses using greedy approach.
  """
  @spec solve([list(non_neg_integer())], [non_neg_integer()]) :: non_neg_integer()
  def solve(buttons, targets) do
    remaining = targets |> Enum.with_index() |> Map.new(fn {v, i} -> {i, v} end)
    buttons_with_idx = Enum.with_index(buttons)

    greedy_solve(buttons_with_idx, remaining, 0)
  end

  defp greedy_solve(buttons, remaining, total_presses) do
    # Check if done
    if Enum.all?(remaining, fn {_k, v} -> v == 0 end) do
      total_presses
    else
      # Find the best button to press
      # Best = can press the most times while making progress
      best =
        buttons
        |> Enum.map(fn {btn, idx} ->
          # How many times can we press this button?
          max_presses = btn |> Enum.map(&Map.get(remaining, &1, 0)) |> Enum.min(fn -> 0 end)
          # Score = total reduction * efficiency
          {idx, btn, max_presses}
        end)
        |> Enum.filter(fn {_idx, _btn, presses} -> presses > 0 end)
        |> Enum.max_by(fn {_idx, btn, presses} -> presses * length(btn) end, fn -> nil end)

      case best do
        nil ->
          # No valid button found - shouldn't happen for valid input
          total_presses

        {_idx, btn, presses} ->
          # Apply the button press
          new_remaining =
            Enum.reduce(btn, remaining, fn j, acc ->
              Map.update(acc, j, 0, &(&1 - presses))
            end)

          greedy_solve(buttons, new_remaining, total_presses + presses)
      end
    end
  end
end
