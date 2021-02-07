defmodule Changelog.Application do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # PromEx uses the new Supervisor child specification
      Changelog.PromEx,
      # Start the endpoint when the application starts
      supervisor(ChangelogWeb.Endpoint, []),
      # Start the Ecto repository
      worker(Changelog.Repo, []),
      # Here you could define other workers and supervisors as children
      worker(UA.Parser, []),
      # worker(Changelog.Worker, [arg1, arg2, arg3]),
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
      worker(Changelog.Scheduler, []),
      worker(Changelog.EpisodeTracker, []),
      worker(Changelog.Metacasts.Filterer.Cache, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Changelog.Supervisor]
    Supervisor.start_link(children, opts)
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
