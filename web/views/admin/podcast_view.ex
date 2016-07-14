defmodule Changelog.Admin.PodcastView do
  use Changelog.Web, :view

  alias Changelog.PodcastView

  def episode_count(podcast), do: PodcastView.episode_count(podcast)

  def vanity_link(podcast) do
    if podcast.vanity_domain do
      external_link podcast.vanity_domain, to: podcast.vanity_domain
    end
  end
end
