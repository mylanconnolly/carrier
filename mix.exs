defmodule Carrier.Mixfile do
  use Mix.Project

  @version "2.0.1"

  def project do
    [
      app: :carrier,
      version: @version,
      elixir: "~> 1.17",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      maintainers: ["Mylan Connolly"],
      description: "Elixir library for interacting with the Smarty API",
      source_url: "https://github.com/mylanconnolly/carrier",
      package: package(),
      docs: docs(),
      deps: deps()
    ]
  end

  defp docs do
    [main: "Carrier", extras: ["README.md"]]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:req, "~> 0.5"},
      {:ex_doc, "~> 0.34", only: :dev}
    ]
  end

  defp package do
    [
      maintainers: ["Mylan Connolly"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/mylanconnolly/carrier"}
    ]
  end
end
