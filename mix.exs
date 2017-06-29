defmodule PatternTap.Mixfile do
  use Mix.Project

  def project do
    [app: :pattern_tap,
     version: "0.3.0",
     elixir: "~> 1.0 or ~> 1.1.0",
     description: """
     Macro for tapping into a pattern match while using the pipe operator
     """,
     package: [
       maintainers: ["Matt Widmann"],
       licenses: ["MIT"],
       links: %{:"Github" => "https://github.com/mgwidmann/elixir-pattern_tap"}
     ],
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    []
  end
end
