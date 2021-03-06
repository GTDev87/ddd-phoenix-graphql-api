defmodule App.Mixfile do
  use Mix.Project

  def project do
    [app: :app,
     version: "0.0.1",
     elixir: "~> 1.5",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {App, []},
     # applications: [:logger, :faker, :postgrex, :ecto],
     extra_applications: [
      :logger,
        :runtime_tools,
        :eventstore,]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["app", "test/support"]
  defp elixirc_paths(_),     do: ["app"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:postgrex, ">= 0.0.0"},
     {:absinthe, "~> 1.4.0-beta.3"},
     {:absinthe_plug, "~> 1.4.0-beta.1"},
     {:commanded, "~> 0.13"},
     {:commanded_ecto_projections, "~> 0.4"},
     {:commanded_eventstore_adapter, "~> 0.1"},
     {:ecto, "~> 2.1-rc"},
     {:uuid, "~> 1.1"},
     {:map_batcher, in_umbrella: true}]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
