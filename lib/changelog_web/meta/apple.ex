defmodule ChangelogWeb.Meta.Apple do
  alias ChangelogWeb.PodcastView

  def apple_podcasts_id(%{view_module: PodcastView, podcast: podcast}) do
    if url = podcast.itunes_url do
      url
      |> String.split("/")
      |> List.last()
      |> String.replace_leading("id", "")
    end
  end
  def apple_podcasts_id(_), do: nil
end
