defmodule Changelog.PodcastView do
  use Changelog.Web, :view

  def cover_art_url(podcast, version) do
    Changelog.CoverArt.url({podcast.cover_art, podcast}, version)
  end

  def dasherized_name(podcast) do
    podcast.name
    |> String.downcase
    |> String.replace(~r/[^\w\s]/, "")
    |> String.replace(" ", "-")
  end
end
