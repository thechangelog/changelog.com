defmodule Changelog.PromEx do
  use PromEx, otp_app: :changelog

  def bearer_token do
    case Application.fetch_env(:changelog, Changelog.PromEx) do
      {:ok, changelog_prom_ex_config} ->
        Keyword.fetch!(changelog_prom_ex_config, :prometheus_bearer_token)

      _error ->
        ""
    end
  end

  @impl true
  def plugins do
    if Mix.env() != :test do
      [
        # PromEx built in plugins
        {PromEx.Plugins.Application, otp_app: :changelog},
        PromEx.Plugins.Beam,
        {PromEx.Plugins.Phoenix, router: ChangelogWeb.Router},
        {PromEx.Plugins.Ecto, otp_app: :changelog, repos: [Changelog.Repo]},
        PromEx.Plugins.Oban
        # Add your own PromEx metrics plugins
        # Changelog.Users.PromEx
      ]
    else
      []
    end
  end

  @impl true
  def dashboard_assigns do
    [
      datasource_id:
        Application.get_env(
          :changelog,
          Changelog.PromEx
        )[:grafana][:datasource_id]
    ]
  end

  @impl true
  def dashboards do
    [
      # PromEx built in dashboard definitions. Remove dashboards that you do not need
      {:prom_ex, "application.json"},
      {:prom_ex, "beam.json"},
      {:prom_ex, "ecto.json"},
      {:prom_ex, "phoenix.json"},
      {:prom_ex, "oban.json"},

      # Add your dashboard definitions here with the format: {:otp_app, "path_in_priv"}
      {:changelog, "/grafana_dashboards/app.json"},
      {:changelog, "/grafana_dashboards/erlang.json"},
      {:changelog, "/grafana_dashboards/ecto.json"},
      {:changelog, "/grafana_dashboards/phoenix.json"}
    ]
  end
end
