defmodule Changelog.Admin.PodcastView do
  use Changelog.Web, :view

  def episode_count(podcast) do
    Changelog.Podcast.episode_count podcast
  end

  def vanity_link(podcast) do
    if podcast.vanity_domain do
      external_link podcast.vanity_domain, to: podcast.vanity_domain
    end
  end
end
