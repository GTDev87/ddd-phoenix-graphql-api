defmodule AppApi.Mixfile do
  use Mix.Project

  def project do
    [app: :app_api,
     version: "0.0.1",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.5",
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
    [mod: {AppApi, []},
     applications: [:phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :logger, :faker, :gettext,
                    :phoenix_ecto, :app]
     ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["app", "test/support"]
  defp elixirc_paths(_),     do: ["app"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.3.0-rc.2"},
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix_ecto, "~> 3.0"},
     {:phoenix_html, "~> 2.6"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:gettext, "~> 0.11"},
     {:cowboy, "~> 1.0"},
     {:absinthe, "~> 1.4.0-beta.3"},
     {:absinthe_plug, "~> 1.4.0-beta.1"},
     {:exconstructor, "~> 1.1"},
     {:poison, "~> 3.1"},
     {:faker, "~> 0.8"},
     {:app, in_umbrella: true},
     {:map_batcher, in_umbrella: true}]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["test": ["test"]]
  end
end
