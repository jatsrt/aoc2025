defmodule Aoc2025.Days.Day12 do
  @moduledoc """
  # Day 12: Christmas Tree Farm

  Fit irregular pentomino-like shapes into rectangular regions.

  ## Part 1

  Count how many regions can fit all their required presents (shapes).

  ## Part 2

  TBD - awaiting puzzle reveal.

  ## Approach

  This is a 2D bin packing problem with irregular shapes. We use backtracking
  with pruning to try all possible placements. Key optimizations:
  - Pre-compute all rotations/flips for each shape
  - Place shapes in order, trying all valid positions
  - Prune early if remaining shapes can't possibly fit
  """

  use Aoc2025.Day

  # Suppress Dialyzer warnings for MapSet opaqueness in recursive functions
  @dialyzer {:nowarn_function, can_fit?: 2}
  @dialyzer {:nowarn_function, backtrack_shapes: 4}
  @dialyzer {:nowarn_function, try_all_positions: 5}

  # Types
  @typedoc "A 2D coordinate {row, col}"
  @type coord :: {non_neg_integer(), non_neg_integer()}

  @typedoc "A shape represented as a set of relative coordinates"
  @type shape :: MapSet.t(coord())

  @typedoc "All orientations of a shape (rotations + flips)"
  @type orientations :: [shape()]

  @typedoc "Map from shape index to all its orientations"
  @type shape_map :: %{non_neg_integer() => orientations()}

  @typedoc "A region with dimensions and required shape counts"
  @type region :: {width :: pos_integer(), height :: pos_integer(), counts :: [non_neg_integer()]}

  @typedoc "Parsed input structure"
  @type parsed :: {shape_map(), [region()]}

  @doc """
  Solve Part 1: Count regions that can fit all their presents.
  """
  @impl true
  @spec part1(String.t()) :: non_neg_integer()
  def part1(input) do
    input
    |> parse()
    |> solve_part1()
  end

  @doc """
  Solve Part 2: TBD
  """
  @impl true
  @spec part2(String.t()) :: non_neg_integer()
  def part2(input) do
    input
    |> parse()
    |> solve_part2()
  end

  @doc """
  Parse the input into shapes and regions.

  ## Input Format

  First section: Shape definitions (index: followed by 3x3 grid of #/.)
  Second section: Regions (WxH: count0 count1 count2 ...)

  ## Output Format

  Tuple of {shape_map, regions} where shape_map has all orientations per shape.
  """
  @impl true
  @spec parse(String.t()) :: parsed()
  def parse(input) do
    # Split into blocks by double newline
    blocks = String.split(input, "\n\n", trim: true)

    # Shapes are blocks starting with "N:" pattern
    # Regions are blocks with "NxN:" pattern
    {shape_blocks, region_blocks} =
      Enum.split_with(blocks, fn block ->
        block |> String.split("\n", parts: 2) |> hd() |> String.match?(~r/^\d+:$/)
      end)

    shapes = parse_shapes(shape_blocks)
    shape_orientations = precompute_orientations(shapes)
    regions = parse_regions(region_blocks)

    {shape_orientations, regions}
  end

  @spec parse_shapes([String.t()]) :: %{non_neg_integer() => shape()}
  defp parse_shapes(blocks) do
    blocks
    |> Enum.map(&parse_single_shape/1)
    |> Map.new()
  end

  defp parse_single_shape(block) do
    [header | rows] = String.split(block, "\n", trim: true)
    index = header |> String.trim_trailing(":") |> String.to_integer()

    coords =
      rows
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, r} ->
        row
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.filter(fn {char, _c} -> char == "#" end)
        |> Enum.map(fn {_char, c} -> {r, c} end)
      end)
      |> MapSet.new()

    {index, coords}
  end

  @spec parse_regions([String.t()]) :: [region()]
  defp parse_regions(blocks) do
    # Regions might be in one block (multiple lines) or spread across blocks
    blocks
    |> Enum.flat_map(fn block -> String.split(block, "\n", trim: true) end)
    |> Enum.map(&parse_single_region/1)
  end

  defp parse_single_region(line) do
    [dims, counts_str] = String.split(line, ": ")
    [width, height] = dims |> String.split("x") |> Enum.map(&String.to_integer/1)
    counts = counts_str |> String.split() |> Enum.map(&String.to_integer/1)
    {width, height, counts}
  end

  # --- Shape Transformations ---

  @spec precompute_orientations(%{non_neg_integer() => shape()}) :: shape_map()
  defp precompute_orientations(shapes) do
    Map.new(shapes, fn {idx, shape} ->
      {idx, all_orientations(shape)}
    end)
  end

  @spec all_orientations(shape()) :: orientations()
  defp all_orientations(shape) do
    # Generate all 8 possible orientations (4 rotations x 2 flips)
    rotations = [shape, rotate_90(shape), rotate_180(shape), rotate_270(shape)]
    flipped = Enum.map(rotations, &flip_horizontal/1)

    (rotations ++ flipped)
    |> Enum.map(&normalize/1)
    |> Enum.uniq()
  end

  defp rotate_90(shape) do
    # (r, c) -> (c, -r)
    shape |> Enum.map(fn {r, c} -> {c, -r} end) |> MapSet.new()
  end

  defp rotate_180(shape) do
    shape |> Enum.map(fn {r, c} -> {-r, -c} end) |> MapSet.new()
  end

  defp rotate_270(shape) do
    # (r, c) -> (-c, r)
    shape |> Enum.map(fn {r, c} -> {-c, r} end) |> MapSet.new()
  end

  defp flip_horizontal(shape) do
    shape |> Enum.map(fn {r, c} -> {r, -c} end) |> MapSet.new()
  end

  @spec normalize(shape()) :: shape()
  defp normalize(shape) do
    # Translate shape so minimum r and c are both 0
    min_r = shape |> Enum.map(&elem(&1, 0)) |> Enum.min()
    min_c = shape |> Enum.map(&elem(&1, 1)) |> Enum.min()

    shape |> Enum.map(fn {r, c} -> {r - min_r, c - min_c} end) |> MapSet.new()
  end

  # --- Part 1 Solution ---

  defp solve_part1({shape_orientations, regions}) do
    # Process regions in parallel for speed
    regions
    |> Task.async_stream(
      fn region -> can_fit?(region, shape_orientations) end,
      timeout: :infinity,
      ordered: false
    )
    |> Enum.count(fn {:ok, result} -> result end)
  end

  @spec can_fit?(region(), shape_map()) :: boolean()
  defp can_fit?({width, height, counts}, shape_orientations) do
    # Build list of shapes to place (expand counts into individual shape indices)
    shapes_to_place =
      counts
      |> Enum.with_index()
      |> Enum.flat_map(fn {count, idx} -> List.duplicate(idx, count) end)

    # Quick check: total cells must fit
    total_cells =
      shapes_to_place
      |> Enum.map(fn idx ->
        shape_orientations[idx] |> hd() |> MapSet.size()
      end)
      |> Enum.sum()

    grid_area = width * height

    if total_cells > grid_area do
      false
    else
      # Build list of shapes to place as {index, orientations} tuples
      shapes_list =
        counts
        |> Enum.with_index()
        |> Enum.flat_map(fn {count, idx} ->
          orientations = shape_orientations[idx]
          List.duplicate({idx, orientations}, count)
        end)
        # Sort by number of orientations (fewer = more constrained = try first)
        |> Enum.sort_by(fn {_idx, orients} -> length(orients) end)

      grid = MapSet.new()
      backtrack_shapes(shapes_list, grid, width, height)
    end
  end

  # Backtrack by placing shapes one at a time
  @spec backtrack_shapes(
          [{non_neg_integer(), orientations()}],
          shape(),
          pos_integer(),
          pos_integer()
        ) ::
          boolean()
  defp backtrack_shapes([], _grid, _width, _height), do: true

  defp backtrack_shapes([{_idx, orientations} | rest], grid, width, height) do
    # Try each orientation, then each valid position
    Enum.any?(orientations, fn orientation ->
      try_all_positions(orientation, rest, grid, width, height)
    end)
  end

  # Try placing a shape orientation at all valid positions
  @spec try_all_positions(
          shape(),
          [{non_neg_integer(), orientations()}],
          shape(),
          pos_integer(),
          pos_integer()
        ) ::
          boolean()
  defp try_all_positions(orientation, rest, grid, width, height) do
    # Get bounding box of shape
    max_r = orientation |> Enum.map(&elem(&1, 0)) |> Enum.max()
    max_c = orientation |> Enum.map(&elem(&1, 1)) |> Enum.max()

    # Try positions in row-major order (top-left to bottom-right)
    Enum.any?(0..(height - max_r - 1)//1, fn start_r ->
      Enum.any?(0..(width - max_c - 1)//1, fn start_c ->
        placed = translate_shape(orientation, start_r, start_c)

        if MapSet.disjoint?(placed, grid) do
          new_grid = MapSet.union(grid, placed)
          backtrack_shapes(rest, new_grid, width, height)
        else
          false
        end
      end)
    end)
  end

  @spec translate_shape(shape(), integer(), integer()) :: shape()
  defp translate_shape(shape, offset_r, offset_c) do
    shape |> Enum.map(fn {r, c} -> {r + offset_r, c + offset_c} end) |> MapSet.new()
  end

  # --- Part 2 Implementation ---

  defp solve_part2(_data) do
    # TODO: Implement part 2 after puzzle reveals
    0
  end
end
