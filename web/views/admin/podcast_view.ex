defmodule Changelog.Admin.PodcastView do
  use Changelog.Web, :view

  import Changelog.Admin.SharedView

  alias Changelog.PodcastView

  def episode_count(podcast), do: PodcastView.episode_count(podcast)

  def status_label(podcast) do
    case podcast.status do
      :draft -> content_tag(:span, "Draft", class: "ui tiny yellow basic label")
      :soon -> content_tag(:span, "Coming Soon", class: "ui tiny yellow basic label")
      :published -> content_tag(:span, "Published", class: "ui tiny green basic label")
      :retired -> content_tag(:span, "Published", class: "ui tiny basic label")
    end
  end

  def status_options do
    PodcastStatus.__enum_map__()
    |> Enum.map(fn({k, _v}) -> {String.capitalize(Atom.to_string(k)), k} end)
  end

  def vanity_link(podcast) do
    if podcast.vanity_domain do
      external_link podcast.vanity_domain, to: podcast.vanity_domain
    end
  end
end
