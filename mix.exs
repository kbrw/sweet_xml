defmodule SweetXml.Mixfile do
  use Mix.Project

  def version, do: "0.7.2"

  @source_url "https://github.com/kbrw/sweet_xml"

  def project do
    [
      app: :sweet_xml,
      version: version(),
      elixir: "~> 1.0",
      description: "A sweet wrapper of :xmerl to help query XML docs",
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
      source_url: @source_url,
      # We need to git tag with the corresponding format.
      source_ref: "v#{version()}",
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
