defmodule Changelog.Admin.PodcastView do
  use Changelog.Web, :view
  use Changelog.Helpers.ViewHelpers

  def vanity_link(podcast) do
    if podcast.vanity_domain do
      external_link podcast.vanity_domain, to: podcast.vanity_domain
    end
  end
end
