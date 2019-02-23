defmodule SweetXml.Mixfile do
  use Mix.Project

  def project do
    [
      app: :sweet_xml,
      version: "0.6.6",
      elixir: "~> 1.0",
      deps: deps(),
      package: [
        maintainers: ["Frank Liu", "Arnaud Wetzel", "Tomáš Brukner", "Vinícius Sales", "Sean Tan"],
        licenses: ["MIT"],
        links: %{
          "GitHub" => "https://github.com/awetzel/sweet_xml"
        }
      ],
      description: """
      An sweet wrapper of :xmerl to help query xml docs
      """
    ]
  end

  def application do
    [applications: [:xmerl]]
  end

  defp deps do
    [{:ex_doc, "~> 0.19", only: :dev}]
  end
end
