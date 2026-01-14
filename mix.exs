defmodule AntColony.MixProject do
  use Mix.Project

  def project do
    [
      app: :ant_colony,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps()
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {AntColony.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Jido Agent Framework (local v2 branch for development)
      {:jido, path: "../jido"},

      # PubSub for agent communication
      {:phoenix_pubsub, "~> 2.1"},

      # Documentation
      {:ex_doc, "~> 0.30", only: :dev, runtime: false},

      # Dialyzer for static analysis
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},

      # Credo for code linting
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end
end
