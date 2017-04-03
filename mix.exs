defmodule Changelog.Mixfile do
  use Mix.Project

  def project do
    [app: :changelog,
     version: "0.0.1",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps(),
     preferred_cli_env: [
        "coveralls": :test,
        "coveralls.html": :test,
        "coveralls.json": :test,
     ],
     test_coverage: [tool: ExCoveralls],
    ]
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Changelog, []},
     applications: [:bamboo, :bamboo_smtp, :phoenix, :phoenix_pubsub,
                    :phoenix_html, :cowboy, :logger, :phoenix_ecto, :postgrex,
                    :ex_machina, :httpoison, :exjsx, :con_cache, :timex_ecto,
                    :nimble_csv, :ex_aws, :briefly, :user_agent_parser,
                    :quantum, :ueberauth_github, :ueberauth_twitter]]
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
     {:phoenix_ecto, "~> 3.0"},
     {:phoenix_html, "~> 2.3"},
     {:postgrex, "~> 0.13"},
     {:timex, "~> 3.0"},
     {:timex_ecto, "~> 3.0"},
     {:scrivener_ecto, "~> 1.0"},
     {:scrivener_html, "~> 1.1"},
     {:cmark, "~> 0.6"},
     {:html_sanitize_ex, "~> 1.1"},
     {:arc_ecto, "~> 0.6.0"},
     {:ecto_enum, "~> 1.0"},
     {:hashids, "~> 2.0"},
     {:bamboo, "~> 0.8"},
     {:bamboo_smtp, "~> 1.3"},
     {:httpoison, "~> 0.11.0"},
     {:con_cache, "~> 0.11.1"},
     {:ex_aws, "~> 1.1"},
     {:exjsx, "~> 4.0"},
     {:nimble_csv, "~> 0.1.0"},
     {:sweet_xml, "~> 0.5"},
     {:briefly, "~> 0.3"},
     {:cowboy, "~> 1.0"},
     {:user_agent_parser, "~> 1.0"},
     {:quantum, ">= 1.8.1"},
     {:oauth, github: "tim/erlang-oauth"},
     {:ueberauth_github, "~> 0.4"},
     {:ueberauth_twitter, "~> 0.2"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:ex_machina, "~> 1.0"},
     {:credo, "~> 0.4", only: [:dev, :test]},
     {:excoveralls, "~> 0.5.7", only: :test},
     {:mock, "~> 0.2.0", only: :test}]
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
