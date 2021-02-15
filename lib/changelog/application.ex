defmodule Changelog.Application do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      Changelog.PromEx,
      ChangelogWeb.Endpoint,
      {Phoenix.PubSub, [name: Changelog.PubSub, adapter: Phoenix.PubSub.PG2]},
      Changelog.Repo,
      # UA.Parser doesn't yet support new Supervisor child specification
      worker(UA.Parser, []),
      {ConCache,
       name: :app_cache, ttl_check_interval: :timer.seconds(1), global_ttl: :timer.seconds(60)},
      Changelog.Scheduler,
      Changelog.EpisodeTracker,
      Changelog.Metacasts.Filterer.Cache,
      {Oban, oban_config()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Changelog.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp oban_config do
    Application.get_env(:changelog, Oban)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ChangelogWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
