defmodule Aoc2025.MixProject do
  use Mix.Project

  def project do
    [
      app: :aoc2025,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),

      # Documentation
      name: "Advent of Code 2025",
      source_url: "https://github.com/jatsrt/aoc2025",
      docs: [
        main: "readme",
        extras: ["README.md"] ++ solution_docs()
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      # Numerical computing for matrix operations
      {:nx, "~> 0.9"},

      # Benchmarking (optional, for performance analysis)
      {:benchee, "~> 1.0", only: :dev, optional: true},

      # Documentation generation
      {:ex_doc, "~> 0.31", only: :dev, runtime: false, optional: true},

      # Static type analysis
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      # Run a specific day: mix day 1
      day: &run_day/1,

      # Run a specific day with example input: mix example 1
      example: &run_example/1,

      # Run tests for a specific day: mix test.day 1
      "test.day": &test_day/1,

      # Generate documentation
      docs: ["docs", &copy_solution_docs/1]
    ]
  end

  defp run_day(args) do
    day = parse_day(args)
    Mix.Task.run("run", ["-e", "Aoc2025.Days.Day#{pad(day)}.run()"])
  end

  defp run_example(args) do
    day = parse_day(args)
    Mix.Task.run("run", ["-e", "Aoc2025.Days.Day#{pad(day)}.run_example()"])
  end

  defp test_day(args) do
    day = parse_day(args)
    Mix.Task.run("test", ["test/days/day#{pad(day)}_test.exs"])
  end

  defp parse_day([day_str | _]) do
    String.to_integer(day_str)
  end

  defp parse_day([]) do
    raise "Please specify a day number, e.g., `mix day 1`"
  end

  defp pad(day), do: day |> Integer.to_string() |> String.pad_leading(2, "0")

  defp solution_docs do
    Path.wildcard("solutions/day*.md")
  end

  defp copy_solution_docs(_) do
    # Hook for copying solution docs to doc output if needed
    :ok
  end
end
