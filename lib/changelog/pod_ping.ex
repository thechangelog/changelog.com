defmodule Changelog.PodPing do

  alias ChangelogWeb.{Endpoint}
  alias ChangelogWeb.Router.Helpers, as: Routes

  def overcast(episode) do
    url = Routes.feed_url(Endpoint, :podcast, episode.podcast.slug)
    HTTPoison.post("https://overcast.fm/ping", {:form, [{"urlprefix", url}]})
  end
end
