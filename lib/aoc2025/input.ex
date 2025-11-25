defmodule Aoc2025.Input do
  @moduledoc """
  Utilities for loading puzzle inputs.

  Input files are stored in:
  - `priv/inputs/day01.txt` - Full puzzle inputs
  - `priv/inputs/examples/day01.txt` - Example inputs from problem descriptions
  """

  @doc """
  Load the puzzle input for a given day.

  ## Example

      Aoc2025.Input.load(1)
      # Loads priv/inputs/day01.txt
  """
  def load(day) when is_integer(day) do
    path = input_path(day)

    case File.read(path) do
      {:ok, content} -> content
      {:error, _} -> raise "Input file not found: #{path}"
    end
  end

  @doc """
  Load the example input for a given day.

  ## Example

      Aoc2025.Input.load_example(1)
      # Loads priv/inputs/examples/day01.txt
  """
  def load_example(day) when is_integer(day) do
    path = example_path(day)

    case File.read(path) do
      {:ok, content} -> content
      {:error, _} -> raise "Example file not found: #{path}"
    end
  end

  @doc """
  Check if input exists for a given day.
  """
  def exists?(day) when is_integer(day) do
    File.exists?(input_path(day))
  end

  @doc """
  Check if example input exists for a given day.
  """
  def example_exists?(day) when is_integer(day) do
    File.exists?(example_path(day))
  end

  defp input_path(day) do
    day_str = day |> Integer.to_string() |> String.pad_leading(2, "0")
    Path.join([priv_dir(), "inputs", "day#{day_str}.txt"])
  end

  defp example_path(day) do
    day_str = day |> Integer.to_string() |> String.pad_leading(2, "0")
    Path.join([priv_dir(), "inputs", "examples", "day#{day_str}.txt"])
  end

  defp priv_dir do
    :code.priv_dir(:aoc2025) |> to_string()
  rescue
    _ -> "priv"
  end
end
