defmodule Changelog.Mixfile do
  use Mix.Project

  def project do
    [app: :changelog,
     version: "0.0.1",
     elixir: "~> 1.3",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases,
     deps: deps]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Changelog, []},
     applications: [:bamboo, :bamboo_smtp, :phoenix, :phoenix_pubsub,
                    :phoenix_html, :cowboy, :logger, :phoenix_ecto, :postgrex,
                    :tzdata, :ex_machina, :httpoison, :exjsx, :con_cache]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.2.0"},
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix_ecto, "~> 3.0-rc"},
     {:postgrex, "~> 0.11.1"},
     {:phoenix_html, "~> 2.3"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:timex, "~> 2.1.4"},
     {:ex_machina, "~> 1.0"},
     {:scrivener_ecto, "~> 1.0"},
     {:scrivener_html, "~> 1.3.0"},
     {:cmark, "~> 0.6"},
     {:html_sanitize_ex, "~> 0.1.0"},
     {:arc, "~> 0.5.2"},
     {:arc_ecto, "~> 0.4.2"},
     {:hashids, "~> 2.0"},
     {:bamboo, "~> 0.6"},
     {:bamboo_smtp, github: "jerodsanto/bamboo_smtp", branch: "fix-email-format"},
     {:ecto_enum, "~> 0.3.0"},
     {:httpoison, "~> 0.9.0"},
     {:exjsx, "~> 3.2.0"},
     {:con_cache, "~> 0.11.1"},
     {:cowboy, "~> 1.0"}]
  end

  # Aliases are shortcut or tasks specific to the current project.
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
