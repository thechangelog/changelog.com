defmodule Changelog.PodPing do

  # alias Changelog.HTTP
  alias ChangelogWeb.PodcastView

  def overcast(episode) do
    url = PodcastView.feed_url(episode.podcast)
    # disabling this until we have instant feed refresh on public
    # HTTP.post("https://overcast.fm/ping", {:form, [{"urlprefix", url}]})
    url
  end
end
