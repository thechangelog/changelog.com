defmodule ChangelogWeb.ObanWeb do
  @moduledoc """
  Simple macro to conditionally load Oban.Web only if already loaded. This
  allows us to include it only in the production release and hence make it a lot
  easier on potential open source contributors, avoiding the problem of sharing
  the oban key and/or them hacking the code to get it working

  Thanks to the team at Glific for showing us the way on this.
  """

  defmacro __using__(_) do
    if Code.ensure_loaded?(Oban.Web.Router) do
      defmodule Resolver do
        @behaviour Oban.Web.Resolver

        @impl true
        def resolve_user(conn) do
          conn.assigns.current_user
        end

        @impl true
        def resolve_access(user) do
          if Changelog.Policies.AdminsOnly.index(user) do
            :all
          else
            {:forbidden, "/in"}
          end
        end
      end

      quote do
        import Oban.Web.Router

        scope "/admin" do
          pipe_through [:browser, :admin]

          oban_dashboard("/oban", resolver: ChangelogWeb.ObanWeb.Resolver)
        end
      end
    end
  end
end
