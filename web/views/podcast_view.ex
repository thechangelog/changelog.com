defmodule Changelog.PodcastView do
  use Changelog.Web, :view

  def cover_art_url(podcast, version) do
    Changelog.CoverArt.url({podcast.cover_art, podcast}, version)
    |> String.replace_leading("priv/static", "/")
  end

  def cover_art_local_path(podcast, version) do
    url = Changelog.CoverArt.url({podcast.cover_art.file_name, podcast}, version)
    Application.app_dir(:changelog, url)
  end

  def dasherized_name(podcast) do
    podcast.name
    |> String.downcase
    |> String.replace(~r/[^\w\s]/, "")
    |> String.replace(" ", "-")
  end
end
