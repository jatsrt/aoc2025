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

  For Part 2, we provide two implementations demonstrating different optimization strategies:

  ### Standard Approach (`part2/1`)
  - Build row ranges: for each y, store valid (min_x, max_x)
  - Check each pair of red tiles, validating rectangle fits by iterating through rows
  - Complexity: O(n² × height) where height is the rectangle's y-span
  - Time: ~30 seconds on puzzle input

  ### Optimized Approach (`part2_optimized/1`)
  - Uses **Sparse Table** data structure for O(1) range-min/max queries
  - Parallelizes pair checking with `Task.async_stream`
  - Complexity: O(n² / cores) with O(1) validation per pair
  - Time: ~1-2 seconds on puzzle input

  The optimized approach demonstrates two powerful Elixir/CS concepts:
  1. **Sparse Tables**: Precompute answers for power-of-2 ranges to answer arbitrary range queries in O(1)
  2. **Task.async_stream**: Distribute embarrassingly parallel work across CPU cores
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

  # ===========================================================================
  # OPTIMIZED IMPLEMENTATION
  # ===========================================================================
  # This section demonstrates advanced optimization techniques:
  # 1. Sparse Tables for O(1) range queries
  # 2. Parallel processing with Task.async_stream
  # ===========================================================================

  @typedoc "Sparse table for O(1) range queries"
  @type sparse_table :: %{non_neg_integer() => %{non_neg_integer() => integer()}}

  @doc """
  Solve Part 2 using optimized approach: Sparse Table + Parallelization.

  This approach reduces rectangle validation from O(height) to O(1) using
  sparse tables, then parallelizes the pair checking across CPU cores.

  ## How Sparse Tables Work

  A sparse table precomputes answers for all power-of-2 sized ranges:
  - Level 0: Individual elements (ranges of size 1)
  - Level 1: Pairs of elements (ranges of size 2)
  - Level 2: Groups of 4 elements (ranges of size 4)
  - etc.

  To query any range [l, r], we find the largest power of 2 that fits (2^k),
  then combine table[k][l] with table[k][r - 2^k + 1]. Since these overlap
  and cover [l, r], min/max operations give the correct answer in O(1).

  ## Performance Comparison

  | Approach   | Validation | Total Complexity | Time     |
  |------------|------------|------------------|----------|
  | Standard   | O(height)  | O(n² × height)   | ~30s     |
  | Optimized  | O(1)       | O(n² / cores)    | ~1-2s    |
  """
  @spec part2_optimized(String.t()) :: non_neg_integer()
  def part2_optimized(input) do
    red_tiles = parse(input)
    row_ranges = build_row_ranges(red_tiles)

    # Build sparse tables for O(1) range queries
    {min_y, max_y, min_x_table, max_x_table} = build_sparse_tables(row_ranges)

    # Parallelize pair checking
    find_max_valid_rectangle_parallel(red_tiles, min_y, max_y, min_x_table, max_x_table)
  end

  @doc """
  Build sparse tables for range-max on min_x values and range-min on max_x values.

  For a rectangle to fit in rows [y1, y2]:
  - max(min_x[y] for y in range) must be <= rect_x_min
  - min(max_x[y] for y in range) must be >= rect_x_max
  """
  @spec build_sparse_tables(%{integer() => {integer(), integer()}}) ::
          {integer(), integer(), sparse_table(), sparse_table()}
  def build_sparse_tables(row_ranges) do
    {min_y, max_y} = row_ranges |> Map.keys() |> Enum.min_max()
    n = max_y - min_y + 1

    # Extract min_x and max_x arrays (indexed from 0)
    min_x_arr = for y <- min_y..max_y, into: %{}, do: {y - min_y, elem(row_ranges[y], 0)}
    max_x_arr = for y <- min_y..max_y, into: %{}, do: {y - min_y, elem(row_ranges[y], 1)}

    # Build sparse tables
    min_x_table = build_sparse_table(min_x_arr, n, &max/2)
    max_x_table = build_sparse_table(max_x_arr, n, &min/2)

    {min_y, max_y, min_x_table, max_x_table}
  end

  defp build_sparse_table(arr, n, combine_fn) do
    max_k = compute_max_level(n)
    initial = %{0 => arr}

    Enum.reduce(1..max_k//1, initial, fn k, table ->
      prev = table[k - 1]
      step = Bitwise.bsl(1, k - 1)
      max_i = n - Bitwise.bsl(1, k)

      level_k =
        for i <- 0..max_i//1, into: %{} do
          {i, combine_fn.(prev[i], prev[i + step])}
        end

      Map.put(table, k, level_k)
    end)
  end

  defp compute_max_level(n) when n > 1, do: floor(:math.log2(n))
  defp compute_max_level(_n), do: 0

  defp sparse_table_query(table, l, r, combine_fn) when l <= r do
    len = r - l + 1
    k = floor(:math.log2(len))
    step = Bitwise.bsl(1, k)

    combine_fn.(table[k][l], table[k][r - step + 1])
  end

  defp sparse_table_query(_table, _l, _r, _combine_fn), do: nil

  @doc """
  Find maximum valid rectangle using parallel processing and O(1) validation.
  """
  @spec find_max_valid_rectangle_parallel(
          [coord()],
          integer(),
          integer(),
          sparse_table(),
          sparse_table()
        ) :: non_neg_integer()
  def find_max_valid_rectangle_parallel(red_tiles, min_y, max_y, min_x_table, max_x_table) do
    # Generate all valid pairs
    pairs = for p1 <- red_tiles, p2 <- red_tiles, different_axes?(p1, p2), do: {p1, p2}

    # Chunk for efficient parallel processing
    num_chunks = System.schedulers_online() * 4
    chunk_size = max(1, div(length(pairs), num_chunks))

    pairs
    |> Enum.chunk_every(chunk_size)
    |> Task.async_stream(
      fn chunk ->
        Enum.reduce(chunk, 0, fn {p1, p2}, acc ->
          if rectangle_fits_sparse?(p1, p2, min_y, max_y, min_x_table, max_x_table) do
            max(acc, rectangle_area(p1, p2))
          else
            acc
          end
        end)
      end,
      timeout: :infinity,
      ordered: false
    )
    |> Enum.reduce(0, fn {:ok, chunk_max}, acc -> max(acc, chunk_max) end)
  end

  defp rectangle_fits_sparse?({x1, y1}, {x2, y2}, min_y, max_y, min_x_table, max_x_table) do
    {rect_x_min, rect_x_max} = Enum.min_max([x1, x2])
    {rect_y_min, rect_y_max} = Enum.min_max([y1, y2])

    check_rectangle_bounds(
      rect_x_min,
      rect_x_max,
      rect_y_min,
      rect_y_max,
      min_y,
      max_y,
      min_x_table,
      max_x_table
    )
  end

  # Out of bounds - reject
  defp check_rectangle_bounds(_, _, rect_y_min, _, min_y, _, _, _) when rect_y_min < min_y,
    do: false

  defp check_rectangle_bounds(_, _, _, rect_y_max, _, max_y, _, _) when rect_y_max > max_y,
    do: false

  # Within bounds - perform O(1) range queries
  defp check_rectangle_bounds(
         rect_x_min,
         rect_x_max,
         rect_y_min,
         rect_y_max,
         min_y,
         _max_y,
         min_x_table,
         max_x_table
       ) do
    l = rect_y_min - min_y
    r = rect_y_max - min_y

    max_of_min_x = sparse_table_query(min_x_table, l, r, &max/2)
    min_of_max_x = sparse_table_query(max_x_table, l, r, &min/2)

    max_of_min_x <= rect_x_min and min_of_max_x >= rect_x_max
  end
end
