defmodule Carrier.Mixfile do
  use Mix.Project

  @version "1.0.5"

  def project do
    [
      app: :carrier,
     version: @version,
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     maintainers: ["Mylan Connolly"],
     description: "Elixir library for interacting with SmartyStreets",
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
      {:httpoison, "~> 0.13"},
      {:poison, "~> 3.1"},
      {:coverex, "~> 1.4.1", only: :test},
      {:ex_doc, "~> 0.10",  only: :dev}
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
