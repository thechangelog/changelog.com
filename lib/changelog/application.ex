defmodule Changelog.Application do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      ChangelogWeb.Endpoint,
      {Phoenix.PubSub, [name: Changelog.PubSub, adapter: Phoenix.PubSub.PG2]},
      Changelog.Repo,
      # UA.Parser doesn't yet support new Supervisor child specification
      worker(UA.Parser, []),
      con_cache_child_spec(
        :app_cache,
        ttl_check_interval: :timer.seconds(1),
        global_ttl: :timer.seconds(60)
      ),
      con_cache_child_spec(
        :news_item_recommendations,
        ttl_check_interval: :timer.seconds(30),
        global_ttl: :timer.minutes(5),
        touch_on_read: false
      ),
      Changelog.EpisodeTracker,
      Changelog.Metacasts.Filterer.Cache,
      {Oban, oban_config()}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Changelog.Supervisor)
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

  defp con_cache_child_spec(name, opts) do
    Supervisor.child_spec(
      {
        ConCache,
        Keyword.put(opts, :name, name)
      },
      id: {ConCache, name}
    )
  end
end
