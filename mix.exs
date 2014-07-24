defmodule SweetXml.Mixfile do
  use Mix.Project

  def project do
    [
      app: :sweet_xml,
      version: "0.1.0",
      elixir: "~> 0.14.2",
      deps: deps,
      package: [
        contributors: ["Frank Liu"]
        licenses: ["MIT"],
        links: ["https://github.com/gniquil/sweet_xml"],
      ],
      description: """
      An sweet wrapper of :xmerl to help query xml docs
      """
    ]
  end

  def application do
    []
  end

  defp deps do
    []
  end
end
