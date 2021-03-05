defmodule SweetXml.Mixfile do
  use Mix.Project

  @source_url "https://github.com/awetzel/sweet_xml"

  def project do
    [
      app: :sweet_xml,
      version: "0.6.6",
      elixir: "~> 1.0",
      description: "An sweet wrapper of :xmerl to help query XML docs",
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  def application do
    [
      applications: [:logger, :xmerl]
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md": [title: "Changelog"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url
    ]
  end

  defp package do
    [
      maintainers: [
        "Frank Liu",
        "Arnaud Wetzel",
        "Tomáš Brukner",
        "Vinícius Sales",
        "Sean Tan"
      ],
      licenses: ["MIT"],
      links: %{
        "Changelog" => "https://hexdocs.pm/sweet_xml/changelog.html",
        "GitHub" => @source_url
      }
    ]
  end
end
