defmodule Aoc2025.Day do
  @moduledoc """
  Behaviour that all daily solutions must implement.

  Each day's solution module should:
  1. `use Aoc2025.Day` to get helper functions and enforce the behaviour
  2. Implement `part1/1` and `part2/1` callbacks
  3. Optionally implement `parse/1` for custom input parsing

  ## Example

      defmodule Aoc2025.Days.Day01 do
        use Aoc2025.Day

        @impl true
        def part1(input) do
          input
          |> parse()
          |> solve_part1()
        end

        @impl true
        def part2(input) do
          input
          |> parse()
          |> solve_part2()
        end
      end

  ## Types

  - `input()` - Raw puzzle input as a string
  - `solution_result()` - Return type for part1/part2 (typically integer or string)
  """

  @typedoc "Raw puzzle input as a string"
  @type input :: String.t()

  @typedoc "Result from solving a puzzle part (typically integer or string)"
  @type solution_result :: integer() | String.t() | term()

  @doc "Solve part 1 of the puzzle"
  @callback part1(input :: input()) :: solution_result()

  @doc "Solve part 2 of the puzzle"
  @callback part2(input :: input()) :: solution_result()

  @doc "Optional: Parse the raw input into a data structure"
  @callback parse(input :: input()) :: term()

  @optional_callbacks [parse: 1]

  defmacro __using__(_opts) do
    quote do
      @behaviour Aoc2025.Day

      import Aoc2025.Day.Helpers

      @doc "Run both parts with the puzzle input"
      def run do
        input = load_input()

        IO.puts("=== Part 1 ===")
        part1_result = part1(input)
        IO.puts("Result: #{inspect(part1_result)}")

        IO.puts("\n=== Part 2 ===")
        part2_result = part2(input)
        IO.puts("Result: #{inspect(part2_result)}")

        {part1_result, part2_result}
      end

      @doc "Run with example input"
      def run_example do
        input = load_example()

        IO.puts("=== Part 1 (Example) ===")
        part1_result = part1(input)
        IO.puts("Result: #{inspect(part1_result)}")

        IO.puts("\n=== Part 2 (Example) ===")
        part2_result = part2(input)
        IO.puts("Result: #{inspect(part2_result)}")

        {part1_result, part2_result}
      end

      @doc "Load the puzzle input for this day"
      def load_input do
        day_number = day_from_module(__MODULE__)
        Aoc2025.Input.load(day_number)
      end

      @doc "Load the example input for this day"
      def load_example do
        day_number = day_from_module(__MODULE__)
        Aoc2025.Input.load_example(day_number)
      end

      defp day_from_module(module) do
        module
        |> Module.split()
        |> List.last()
        |> String.replace("Day", "")
        |> String.to_integer()
      end
    end
  end
end

defmodule Aoc2025.Day.Helpers do
  @moduledoc """
  Common helper functions available to all day solutions.

  These are automatically imported when you `use Aoc2025.Day`.

  ## Types

  - `coord()` - A 2D coordinate as `{x, y}` tuple
  - `grid()` - A map from coordinates to characters
  """

  @typedoc "A 2D coordinate as {x, y} tuple"
  @type coord :: {non_neg_integer(), non_neg_integer()}

  @typedoc "A map from coordinates to single-character strings"
  @type grid :: %{coord() => String.t()}

  @doc """
  Split input into lines, removing empty trailing lines.

  ## Example

      iex> lines("1\\n2\\n3\\n")
      ["1", "2", "3"]
  """
  @spec lines(String.t()) :: [String.t()]
  def lines(input) do
    input
    |> String.trim()
    |> String.split("\n")
  end

  @doc """
  Split input into lines and convert each to integer.

  ## Example

      iex> integers("1\\n2\\n3\\n")
      [1, 2, 3]
  """
  @spec integers(String.t()) :: [integer()]
  def integers(input) do
    input
    |> lines()
    |> Enum.map(&String.to_integer/1)
  end

  @doc """
  Split input into paragraphs (blocks separated by blank lines).

  ## Example

      iex> paragraphs("a\\nb\\n\\nc\\nd")
      ["a\\nb", "c\\nd"]
  """
  @spec paragraphs(String.t()) :: [String.t()]
  def paragraphs(input) do
    input
    |> String.trim()
    |> String.split(~r/\n\n+/)
  end

  @doc """
  Parse input as a 2D grid, returning a map of {x, y} => character.

  ## Example

      iex> grid("AB\\nCD")
      %{{0, 0} => "A", {1, 0} => "B", {0, 1} => "C", {1, 1} => "D"}
  """
  @spec grid(String.t()) :: grid()
  def grid(input) do
    input
    |> lines()
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {char, x} -> {{x, y}, char} end)
    end)
    |> Map.new()
  end

  @doc """
  Extract all integers from a string.

  ## Example

      iex> extract_integers("Game 1: 3 blue, 4 red")
      [1, 3, 4]
  """
  @spec extract_integers(String.t()) :: [integer()]
  def extract_integers(string) do
    ~r/-?\d+/
    |> Regex.scan(string)
    |> List.flatten()
    |> Enum.map(&String.to_integer/1)
  end

  @doc """
  Extract all ranges from a string in "start-end" format.

  Useful for parsing range specifications like "3-5" or "10-14".
  Unlike `extract_integers/1`, this treats the hyphen as a delimiter,
  not a negative sign.

  ## Example

      iex> extract_ranges("3-5")
      [3..5]

      iex> extract_ranges("rows 3-5, cols 10-20")
      [3..5, 10..20]
  """
  @spec extract_ranges(String.t()) :: [Range.t()]
  def extract_ranges(string) do
    ~r/(\d+)-(\d+)/
    |> Regex.scan(string, capture: :all_but_first)
    |> Enum.map(fn [start, finish] ->
      String.to_integer(start)..String.to_integer(finish)
    end)
  end
end
