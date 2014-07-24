defmodule SweetXml.Mixfile do
  use Mix.Project

  def project do
    [app: :sweet_xml,
     version: "0.1.0",
     elixir: "~> 0.14.2",
     name: "SweetXml",
     source_url: "https://github.com/gniquil/sweet_xml",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: []]
  end

  # Dependencies can be hex.pm packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    []
  end
end
