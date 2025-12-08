defmodule Aoc2025.Days.Day08 do
  @moduledoc """
  # Day 8: Playground

  Connect junction boxes with strings of lights to form circuits.

  ## Part 1

  Given 3D coordinates of junction boxes, connect the 1000 closest pairs.
  Find the product of the sizes of the three largest circuits.

  ## Part 2

  Continue connecting until all boxes form a single circuit.
  Return the product of the X coordinates of the last two boxes that
  merge separate circuits.

  ## Approach

  This is a classic Union-Find (Disjoint Set Union) problem:
  1. Parse all 3D coordinates
  2. Calculate all pairwise distances
  3. Sort pairs by distance (ascending)
  4. Use Union-Find to track which boxes are in which circuit
  5. Connect the closest pairs, merging circuits when needed
  6. Find the three largest circuits and multiply their sizes
  """

  use Aoc2025.Day

  @typedoc "A 3D coordinate representing a junction box position"
  @type coord3d :: {integer(), integer(), integer()}

  @typedoc "Index of a junction box in our list"
  @type box_index :: non_neg_integer()

  @typedoc "Union-Find parent map: box_index => parent_index"
  @type parent_map :: %{box_index() => box_index()}

  @typedoc "Union-Find rank map for union by rank optimization"
  @type rank_map :: %{box_index() => non_neg_integer()}

  @typedoc "Union-Find state containing parent and rank maps"
  @type uf_state :: {parent_map(), rank_map()}

  @typedoc "A pair of box indices with their squared distance"
  @type distance_pair :: {number(), box_index(), box_index()}

  @doc """
  Solve Part 1: Connect 1000 closest pairs and find product of 3 largest circuits.
  """
  @impl true
  @spec part1(String.t()) :: non_neg_integer()
  def part1(input) do
    input
    |> parse()
    |> solve_part1()
  end

  @doc """
  Solve Part 2: Find the last connection that merges separate circuits,
  return product of X coordinates.
  """
  @impl true
  @spec part2(String.t()) :: non_neg_integer()
  def part2(input) do
    input
    |> parse()
    |> solve_part2()
  end

  @doc """
  Parse the input into a list of 3D coordinates.

  ## Input Format

  One junction box per line as "X,Y,Z" coordinates.

  ## Output Format

  List of `{x, y, z}` tuples.
  """
  @impl true
  @spec parse(String.t()) :: [coord3d()]
  def parse(input) do
    input
    |> lines()
    |> Enum.map(&parse_coord/1)
  end

  defp parse_coord(line) do
    [x, y, z] = line |> String.split(",") |> Enum.map(&String.to_integer/1)
    {x, y, z}
  end

  # --- Part 1 Implementation ---

  defp solve_part1(coords) do
    connect_closest_pairs(coords, 1000)
  end

  @doc """
  Connect the closest `num_connections` pairs of junction boxes and return
  the product of the three largest circuit sizes.

  This is the core algorithm used by both parts, exposed for testing with
  different connection counts.
  """
  @spec connect_closest_pairs([coord3d()], non_neg_integer()) :: non_neg_integer()
  def connect_closest_pairs(coords, num_connections) do
    n = length(coords)
    coords_indexed = coords |> Enum.with_index() |> Map.new(fn {coord, i} -> {i, coord} end)

    # Calculate all pairwise distances (using squared distance to avoid sqrt)
    distance_pairs = calculate_all_distances(coords_indexed, n)

    # Sort by distance
    sorted_pairs = Enum.sort_by(distance_pairs, fn {dist, _i, _j} -> dist end)

    # Initialize Union-Find: each box is its own parent
    initial_uf = initialize_uf(n)

    # Connect the closest num_connections pairs
    final_uf =
      sorted_pairs
      |> Enum.take(num_connections)
      |> Enum.reduce(initial_uf, fn {_dist, i, j}, uf ->
        union(uf, i, j)
      end)

    # Find sizes of all circuits
    circuit_sizes = get_circuit_sizes(final_uf, n)

    # Multiply the three largest
    circuit_sizes
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.product()
  end

  defp calculate_all_distances(coords_map, n) do
    for i <- 0..(n - 2),
        j <- (i + 1)..(n - 1) do
      {distance_squared(coords_map[i], coords_map[j]), i, j}
    end
  end

  defp distance_squared({x1, y1, z1}, {x2, y2, z2}) do
    dx = x2 - x1
    dy = y2 - y1
    dz = z2 - z1
    dx * dx + dy * dy + dz * dz
  end

  # --- Union-Find Implementation ---

  defp initialize_uf(n) do
    parent = Map.new(0..(n - 1), fn i -> {i, i} end)
    rank = Map.new(0..(n - 1), fn i -> {i, 0} end)
    {parent, rank}
  end

  defp find({parent, _rank} = uf, x) do
    case parent[x] == x do
      true ->
        {x, uf}

      false ->
        {root, {new_parent, new_rank}} = find(uf, parent[x])
        # Path compression
        {root, {Map.put(new_parent, x, root), new_rank}}
    end
  end

  defp union(uf, x, y) do
    {root_x, uf} = find(uf, x)
    {root_y, {parent, rank}} = find(uf, y)
    merge_roots(root_x, root_y, parent, rank)
  end

  defp merge_roots(root, root, parent, rank), do: {parent, rank}

  defp merge_roots(root_x, root_y, parent, rank) do
    union_by_rank(root_x, root_y, rank[root_x], rank[root_y], parent, rank)
  end

  defp union_by_rank(root_x, root_y, rank_x, rank_y, parent, rank) when rank_x < rank_y do
    {Map.put(parent, root_x, root_y), rank}
  end

  defp union_by_rank(root_x, root_y, rank_x, rank_y, parent, rank) when rank_x > rank_y do
    {Map.put(parent, root_y, root_x), rank}
  end

  defp union_by_rank(root_x, root_y, rank_x, _rank_y, parent, rank) do
    {Map.put(parent, root_y, root_x), Map.put(rank, root_x, rank_x + 1)}
  end

  defp get_circuit_sizes(uf, n) do
    # Find the root for each node and count sizes
    {roots, _final_uf} =
      Enum.reduce(0..(n - 1), {[], uf}, fn i, {roots, current_uf} ->
        {root, new_uf} = find(current_uf, i)
        {[root | roots], new_uf}
      end)

    roots
    |> Enum.frequencies()
    |> Map.values()
  end

  # --- Part 2 Implementation ---

  defp solve_part2(coords) do
    n = length(coords)
    coords_indexed = coords |> Enum.with_index() |> Map.new(fn {coord, i} -> {i, coord} end)

    # Calculate all pairwise distances and sort
    sorted_pairs =
      coords_indexed
      |> calculate_all_distances(n)
      |> Enum.sort_by(fn {dist, _i, _j} -> dist end)

    initial_uf = initialize_uf(n)

    # We need n-1 successful merges to form a single circuit
    # Track the last pair that performed a real merge
    {_final_uf, last_merge} = find_last_merge(sorted_pairs, initial_uf, n - 1, nil)

    # Return product of X coordinates
    {i, j} = last_merge
    {x1, _y1, _z1} = coords_indexed[i]
    {x2, _y2, _z2} = coords_indexed[j]
    x1 * x2
  end

  defp find_last_merge(_pairs, uf, 0, last_merge), do: {uf, last_merge}

  defp find_last_merge([{_dist, i, j} | rest], uf, merges_needed, last_merge) do
    case try_union(uf, i, j) do
      {:merged, new_uf} ->
        find_last_merge(rest, new_uf, merges_needed - 1, {i, j})

      {:same_circuit, new_uf} ->
        find_last_merge(rest, new_uf, merges_needed, last_merge)
    end
  end

  defp try_union(uf, x, y) do
    {root_x, uf} = find(uf, x)
    {root_y, {parent, rank}} = find(uf, y)
    try_merge_roots(root_x, root_y, parent, rank)
  end

  defp try_merge_roots(root, root, parent, rank), do: {:same_circuit, {parent, rank}}

  defp try_merge_roots(root_x, root_y, parent, rank) do
    {:merged, union_by_rank(root_x, root_y, rank[root_x], rank[root_y], parent, rank)}
  end
end
