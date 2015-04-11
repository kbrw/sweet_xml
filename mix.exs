defmodule SweetXml.Mixfile do
  use Mix.Project

  def project do
    [
      app: :sweet_xml,
      version: "0.2.0",
      elixir: "~> 1.0.0-rc2",
      deps: deps,
      package: [
        contributors: ["Frank Liu", "Arnaud Wetzel", "Tomáš Brukner"],
        licenses: ["MIT"],
        links: %{
          "GitHub" => "https://github.com/gniquil/sweet_xml"
        }
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
