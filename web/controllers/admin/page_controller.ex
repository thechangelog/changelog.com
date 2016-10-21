defmodule Changelog.Admin.PageController do
  use Changelog.Web, :controller

  alias Changelog.{Episode, Newsletter, Post}

  def index(conn, _params) do
    newsletters = [
      %Newsletter{name: "Weekly", list_id: "eddd53c07cf9e23029fe8a67fe84731f", web_id: "82E49C221D20C4F7"},
      %Newsletter{name: "Nightly", list_id: "95a8fbc221a2240ac7469d661bac650a", web_id: "82E49C221D20C4F7"},
      %Newsletter{name: "Go Time", list_id: "96f7328735b814e82d384ce1ddaf8420", web_id: "B4546FE361E47720"}
    ]
    |> Enum.map(fn(newsletter) ->
      stats = ConCache.get_or_store(:app_cache, "newsletter_#{newsletter.list_id}_stats", fn() ->
        %ConCache.Item{value: Craisin.List.stats(newsletter.list_id), ttl: :timer.hours(12)}
      end)

      %Newsletter{newsletter | stats: stats}
    end)

    draft_episodes =
      Episode.unpublished
      |> Episode.newest_last(:recorded_at)
      |> Repo.all
      |> Episode.preload_podcast

    draft_posts =
      Post.unpublished
      |> Post.newest_last(:inserted_at)
      |> Repo.all
      |> Post.preload_author

    render(conn, :index, newsletters: newsletters, draft_episodes: draft_episodes, draft_posts: draft_posts)
  end
end
