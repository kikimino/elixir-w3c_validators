defmodule W3cValidators.MixProject do
  use Mix.Project

  @description """
  Elixir wrapper for the World Wide Web Consortium’s online validation services.
  """
  @source_url "https://github.com/spk/elixir-w3c_validators"
  @version_path Path.join([__DIR__, "VERSION"])
  # recompile when version change
  @external_resource @version_path
  @version @version_path |> File.read!() |> String.trim()

  def project do
    [
      app: :w3c_validators,
      version: @version,
      description: @description,
      source_url: @source_url,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      docs: [
        main: "readme",
        extras: [
          "README.md",
          "History.md"
        ]
      ],
      package: package(),
      aliases: aliases(),
      deps: deps(),
      dialyzer: [
        plt_add_deps: :apps_direct,
        plt_add_apps: [:mix, :ex_unit],
        plt_ignore_apps: [:mnesia]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4"},
      {:httpoison, "~> 2.0"},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:credo, "~> 1.1", only: [:dev, :test], runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Laurent Arnoud"],
      licenses: ["MIT"],
      links: %{
        Changelog: "#{@source_url}/blob/master/History.md",
        GitHub: @source_url
      }
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get"],
      lint: [
        "format --check-formatted",
        "compile --warnings-as-errors",
        "credo",
        "dialyzer"
      ]
    ]
  end
end
