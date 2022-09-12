defmodule Changelog.Mixfile do
  use Mix.Project

  Code.compile_file("config/secret_or_env.exs")

  def project do
    [
      app: :changelog,
      version: System.get_env("APP_VERSION", "0.0.1"),
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      preferred_cli_env: [coveralls: :test, "coveralls.circle": :test],
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Changelog.Application, []}, extra_applications: [:logger, :runtime_tools, :iex]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.6.10"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.6"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:plug_cowboy, "~> 2.5"},
      {:oban, "~> 2.8"},
      {:prom_ex, "~> 1.7.0"},
      {:unplug, "~> 1.0.0"},
      {:postgrex, ">= 0.0.0"},
      {:timex, "~> 3.0"},
      {:scrivener_ecto, "~> 2.0"},
      {:scrivener_html, "~> 1.8", github: "jerodsanto/scrivener_html", branch: "phx-1-6"},
      {:cmark, "~> 0.6"},
      {:floki, "~> 0.33.0"},
      {:html_sanitize_ex, "~> 1.1"},
      {:waffle_ecto, "~> 0.0"},
      {:ecto_enum, "~> 1.0"},
      {:hashids, "~> 2.0"},
      {:bamboo_phoenix, "~> 1.0.0"},
      {:bamboo_smtp, "~> 4.2"},
      {:httpoison, "~> 1.0", override: true},
      {:jason, "~> 1.0"},
      {:con_cache, "~> 1.0.0"},
      {:ex_aws, "~> 2.2"},
      {:ex_aws_s3, "~> 2.3"},
      {:nimble_csv, "~> 1.2.0"},
      {:sweet_xml, "~> 0.6"},
      {:user_agent_parser, "~> 1.0"},
      {:oauth, github: "tim/erlang-oauth"},
      # Explicit require of 1.2 forces ueberauth to use newer version that fixes :crypto.hmac/3 undefined error on OTP 24
      # see also https://github.com/ueberauth/ueberauth/issues/143
      {:oauther, "~> 1.2"},
      {:ueberauth, "~> 0.9.0", override: true},
      {:ueberauth_github, "~> 0.4"},
      {:ueberauth_twitter, "~> 0.4"},
      {:ex_machina, "~> 2.0"},
      {:sentry, "~> 8.0"},
      {:html_entities, "~> 0.3"},
      {:algolia, "~> 0.8.0"},
      {:tzdata, "~> 1.1.0"},
      {:icalendar, "~> 1.0"},
      {:shopify, "~> 0.4"},
      {:id3vx, "~> 0.0.1-rc6"},
      {:credo, "~> 1.6.4", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
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
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
