defmodule Zochat.MixProject do
  use Mix.Project

  def project do
    [
      app: :zochat,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :cowboy, :poison, :mongodb, :poolboy],
      mod: {Zochat.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 2.6"},
      {:poison, "~> 3.1"},
      {:redix, "~> 0.10.2"},
      {:gproc, "~> 0.8.0"},
      {:joken, "~> 2.1"},
      {:distillery, "~> 2.1"},
      {:config_tuples, "~> 0.3.0"},
      {:mongodb, "~> 0.5.1"},
      {:poolboy, "~> 1.5"},
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
