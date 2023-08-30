defmodule ChangelogWeb.ApiController do
  use ChangelogWeb, :controller

  alias Changelog.{Episode, Podcast, Repo}

  def oembed(conn, params) do
    [podcast_slug, episode_slug] =
      case Map.get(params, "url") do
        nil -> ["nope", "nope"]
        url -> String.split(url, "/") |> Enum.take(-2)
      end

    podcast = Repo.get_by!(Podcast, slug: podcast_slug)

    episode =
      assoc(podcast, :episodes)
      |> Episode.published()
      |> Repo.get_by!(slug: episode_slug)

    embed_url = url(~p"/#{podcast.slug}/#{episode.slug}/embed")

    response = %{
      type: "rich",
      version: "1.0",
      width: 500,
      height: 220,
      html:
        ~s{<iframe src="#{embed_url}" width="100%" height="220" scrolling="no" frameborder="no"></iframe>}
    }

    conn
    |> put_status(200)
    |> json(response)
  end
end
