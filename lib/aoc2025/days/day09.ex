defmodule Aoc2025.Days.Day09 do
  @moduledoc """
  # Day 09: Movie Theater

  Finding the largest rectangle that can be formed using red tiles as opposite corners.

  ## Part 1

  Given a list of red tile coordinates, find the largest rectangle where two red tiles
  form opposite corners. The rectangle sides are axis-aligned.

  ## Part 2

  The rectangle must only contain red or green tiles. Green tiles are:
  - Lines connecting consecutive red tiles in input order (wrapping around)
  - All tiles inside the closed polygon formed by the boundary

  ## Approach

  For Part 1, we use a brute-force O(n²) approach: check every pair of points and
  calculate the rectangle area they would form as opposite corners.

  For Part 2, we first build the polygon boundary (red tiles + connecting green lines),
  then fill the interior using scanline/ray-casting. Finally, we find the largest
  rectangle where all tiles are valid (red or green).
  """

  use Aoc2025.Day

  @typedoc "A coordinate on the tile grid"
  @type coord :: {non_neg_integer(), non_neg_integer()}

  @doc """
  Solve Part 1: Find the largest rectangle area using two red tiles as opposite corners.
  """
  @impl true
  @spec part1(String.t()) :: non_neg_integer()
  def part1(input), do: input |> parse() |> find_max_rectangle_area()

  @doc """
  Solve Part 2: Find the largest rectangle using only red and green tiles.
  """
  @impl true
  @spec part2(String.t()) :: non_neg_integer()
  def part2(input) do
    red_tiles = parse(input)
    row_ranges = build_row_ranges(red_tiles)
    find_max_valid_rectangle_fast(red_tiles, row_ranges)
  end

  @doc """
  Parse the input into a list of coordinates.

  ## Input Format

  Each line contains two comma-separated integers representing x,y coordinates.

  ## Output Format

  A list of {x, y} tuples representing the coordinates of red tiles.
  """
  @impl true
  @spec parse(String.t()) :: [coord()]
  def parse(input), do: input |> lines() |> Enum.map(&parse_coord/1)

  defp parse_coord(line), do: line |> extract_integers() |> List.to_tuple()

  @doc """
  Find the maximum rectangle area from a list of coordinates.

  For each pair of points, calculates the area of the rectangle they would form
  as opposite corners. The area is inclusive of both corner tiles, so a rectangle
  from (2,1) to (11,5) has width = |11-2|+1 = 10 and height = |5-1|+1 = 5.
  """
  @spec find_max_rectangle_area([coord()]) :: non_neg_integer()
  def find_max_rectangle_area(coords) do
    for p1 <- coords,
        p2 <- coords,
        different_axes?(p1, p2),
        reduce: 0 do
      acc -> max(acc, rectangle_area(p1, p2))
    end
  end

  defp different_axes?({x1, y1}, {x2, y2}), do: x1 != x2 and y1 != y2

  # Area is inclusive of both corner tiles (+1 for width and height)
  defp rectangle_area({x1, y1}, {x2, y2}), do: (abs(x2 - x1) + 1) * (abs(y2 - y1) + 1)

  # --- Part 2 Implementation ---

  @doc """
  Build row ranges: for each y, store the min and max valid x.

  This is an optimized representation using the scanline algorithm for
  rectilinear polygons. For each row, we find vertical edges that cross it,
  sort them by x, and determine the valid range.
  """
  @spec build_row_ranges([coord()]) :: %{integer() => {integer(), integer()}}
  def build_row_ranges(red_tiles) do
    # Separate edges into vertical and horizontal
    edges =
      red_tiles
      |> Enum.chunk_every(2, 1, [hd(red_tiles)])
      |> Enum.map(fn [{x1, y1}, {x2, y2}] -> {{x1, y1}, {x2, y2}} end)

    vertical_edges =
      edges
      |> Enum.filter(fn {{x1, _}, {x2, _}} -> x1 == x2 end)
      |> Enum.map(fn {{x, y1}, {_, y2}} ->
        {y_min, y_max} = Enum.min_max([y1, y2])
        {x, y_min, y_max}
      end)

    horizontal_edges =
      edges
      |> Enum.filter(fn {{_, y1}, {_, y2}} -> y1 == y2 end)
      |> Enum.map(fn {{x1, y}, {x2, _}} ->
        {x_min, x_max} = Enum.min_max([x1, x2])
        {y, x_min, x_max}
      end)

    # Find y range
    {min_y, max_y} = red_tiles |> Enum.map(&elem(&1, 1)) |> Enum.min_max()

    # For each row, compute valid x range
    for y <- min_y..max_y, into: %{} do
      {x_min, x_max} = compute_row_range(y, vertical_edges, horizontal_edges)
      {y, {x_min, x_max}}
    end
  end

  defp compute_row_range(y, vertical_edges, horizontal_edges) do
    h_x_values =
      horizontal_edges
      |> Enum.filter(fn {hy, _, _} -> hy == y end)
      |> Enum.flat_map(fn {_, x_min, x_max} -> [x_min, x_max] end)

    v_x_values =
      vertical_edges
      |> Enum.filter(fn {_x, y_min, y_max} -> y >= y_min and y <= y_max end)
      |> Enum.map(fn {x, _, _} -> x end)

    x_range_from_crossings(v_x_values ++ h_x_values)
  end

  defp x_range_from_crossings([]), do: {0, 0}
  defp x_range_from_crossings(xs), do: Enum.min_max(xs)

  @doc """
  Find the maximum valid rectangle area using row ranges for fast validation.
  """
  @spec find_max_valid_rectangle_fast([coord()], %{integer() => {integer(), integer()}}) ::
          non_neg_integer()
  def find_max_valid_rectangle_fast(red_tiles, row_ranges) do
    for p1 <- red_tiles,
        p2 <- red_tiles,
        different_axes?(p1, p2),
        rectangle_fits_in_region?(p1, p2, row_ranges),
        reduce: 0 do
      acc -> max(acc, rectangle_area(p1, p2))
    end
  end

  defp rectangle_fits_in_region?({x1, y1}, {x2, y2}, row_ranges) do
    {rect_x_min, rect_x_max} = Enum.min_max([x1, x2])
    {y_min, y_max} = Enum.min_max([y1, y2])

    Enum.all?(y_min..y_max, fn y ->
      row_contains_x_range?(row_ranges, y, rect_x_min, rect_x_max)
    end)
  end

  defp row_contains_x_range?(row_ranges, y, rect_x_min, rect_x_max) do
    case Map.get(row_ranges, y) do
      {row_x_min, row_x_max} -> rect_x_min >= row_x_min and rect_x_max <= row_x_max
      nil -> false
    end
  end
end
