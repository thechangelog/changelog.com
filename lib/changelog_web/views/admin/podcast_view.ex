defmodule ChangelogWeb.Admin.PodcastView do
  use ChangelogWeb, :admin_view

  alias Changelog.{EpisodeStat, Podcast, Repo, Topic}
  alias ChangelogWeb.PodcastView

  def episode_count(podcast), do: PodcastView.episode_count(podcast)

  def last_stat(podcast) do
    podcast
    |> Ecto.assoc(:episode_stats)
    |> EpisodeStat.newest_first()
    |> EpisodeStat.limit(1)
    |> Repo.one()
  end

  def position_options do
    1..Repo.count(Podcast.not_retired())
  end

  def status_label(podcast) do
    case podcast.status do
      :draft -> content_tag(:span, "Draft", class: "ui tiny yellow basic label")
      :soon -> content_tag(:span, "Coming Soon", class: "ui tiny yellow basic label")
      :published -> content_tag(:span, "Published", class: "ui tiny green basic label")
      :retired -> content_tag(:span, "Retired", class: "ui tiny basic label")
    end
  end

  def status_options do
    Podcast.Status.__enum_map__()
    |> Enum.map(fn {k, _v} -> {String.capitalize(Atom.to_string(k)), k} end)
  end

  def vanity_link(podcast) do
    if podcast.vanity_domain do
      SharedHelpers.external_link(SharedHelpers.domain_name(podcast.vanity_domain),
        to: podcast.vanity_domain
      )
    end
  end
end
