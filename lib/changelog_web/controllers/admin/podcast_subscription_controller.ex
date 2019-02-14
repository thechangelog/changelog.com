defmodule ChangelogWeb.Admin.PodcastSubscriptionController do
  use ChangelogWeb, :controller

  alias Changelog.{Podcast, Subscription}

  plug :assign_podcast
  plug Authorize, [Policies.Episode, :podcast]

  # pass assigned podcast as a function arg
  def action(conn, _) do
    arg_list = [conn, conn.params, conn.assigns.podcast]
    apply(__MODULE__, action_name(conn), arg_list)
  end

  def index(conn, params, podcast) do
    page =
      Subscription.on_podcast(podcast)
      |> Subscription.newest_first()
      |> Subscription.preload_person()
      |> Repo.paginate(params)

    conn
    |> assign(:subscriptions, page.entries)
    |> assign(:page, page)
    |> render(:index)
  end

  defp assign_podcast(conn = %{params: %{"podcast_id" => slug}}, _) do
    podcast = Podcast |> Repo.get_by!(slug: slug) |> Podcast.preload_hosts
    assign(conn, :podcast, podcast)
  end
end
