defmodule Changelog.Mixfile do
  use Mix.Project

  def project do
    [
      app: :changelog,
      version: "0.0.1",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps(),
      preferred_cli_env: [
         coveralls: :test,
         "coveralls.html": :test,
         "coveralls.json": :test],
      test_coverage: [tool: ExCoveralls],
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Changelog.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.0", override: true},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:phoenix_html, "~> 2.10"},
      {:postgrex, ">= 0.0.0"},
      {:timex, "~> 3.0"},
      {:timex_ecto, "~> 3.0"},
      {:scrivener_ecto, "~> 1.0"},
      {:scrivener_html, "~> 1.1"},
      {:cmark, "~> 0.6"},
      {:html_sanitize_ex, "~> 1.1"},
      {:arc_ecto, "~> 0.7.0"},
      {:ecto_enum, "~> 1.0"},
      {:hashids, "~> 2.0"},
      {:bamboo, "~> 0.8"},
      {:bamboo_smtp, "~> 1.3"},
      {:httpoison, "~> 1.0", override: true},
      {:con_cache, "~> 0.13.0"},
      {:plug_ets_cache, "~> 0.3.0"},
      {:exjsx, "~> 3.2.1 or ~> 4.0"},
      {:ex_aws, "~> 1.1"}, # can't upgrade to 2.0 until arc supports it
      {:nimble_csv, "~> 0.4"},
      {:sweet_xml, "~> 0.5"},
      {:briefly, "~> 0.3"},
      {:cowboy, "~> 1.0"},
      {:user_agent_parser, "~> 1.0"},
      {:quantum, ">= 2.1.0"},
      {:oauth, github: "tim/erlang-oauth"},
      {:ueberauth_github, "~> 0.4"},
      {:ueberauth_twitter, github: "jerodsanto/ueberauth_twitter"},
      {:ex_machina, "~> 2.0"},
      {:rollbax, "~> 0.8.2"},
      {:html_entities, "~> 0.3"},
      {:algolia, "~> 0.6.5"},
      {:credo, "~> 0.4", only: [:dev, :test]},
      {:excoveralls, "~> 0.6", only: :test},
      {:mock, "~> 0.3.0", only: :test}
   ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
