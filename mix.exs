defmodule BE.MixProject do
  use Mix.Project

  def project do
    [
      app: :backend,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      # Need [:wx, :observer, :runtime_tools] for :observer.start() to work.
      included_applications: [:odbc],
      extra_applications: [:logger, :wx, :observer, :runtime_tools],
      mod: {BE, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.7.12", only: [:dev, :test], runtime: false},
      {:postgrex, "~> 0.20.0"}
    ]
  end
end
