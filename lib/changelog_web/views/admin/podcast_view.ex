defmodule ChangelogWeb.Admin.PodcastView do
  use ChangelogWeb, :admin_view

  alias Changelog.{EpisodeStat, Podcast, Repo, Topic}
  alias ChangelogWeb.{PodcastView}
  alias ChangelogWeb.Admin.EpisodeView

  def cover_url(podcast), do: PodcastView.cover_url(podcast)
  def cover_url(podcast, version), do: PodcastView.cover_url(podcast, version)

  def episode_count(podcast), do: PodcastView.episode_count(podcast)

  def last_stat(podcast) do
    podcast
    |> Ecto.assoc(:episode_stats)
    |> EpisodeStat.newest_first()
    |> EpisodeStat.limit(1)
    |> Repo.one()
  end

  def position_options do
    Range.new(1, Repo.count(Podcast.public()), 1)
  end

  def subscribers_count(%{subscribers: nil}), do: 0
  def subscribers_count(%{subscribers: subs}), do: subs |> Map.values() |> Enum.sum()

  def status_label(podcast) do
    case podcast.status do
      :draft -> content_tag(:span, "Draft", class: "ui tiny yellow basic label")
      :soon -> content_tag(:span, "Coming Soon", class: "ui tiny yellow basic label")
      :publishing -> content_tag(:span, "Publishing", class: "ui tiny green basic label")
      :inactive -> content_tag(:span, "Inactive", class: "ui tiny red basic label")
      :archived -> content_tag(:span, "Archived", class: "ui tiny basic label")
    end
  end

  def status_options do
    Podcast.Status.__enum_map__()
    |> Enum.map(fn {k, _v} -> {String.capitalize(Atom.to_string(k)), k} end)
  end

  def vanity_link(podcast) do
    if podcast.vanity_domain do
      link(SharedHelpers.domain_name(podcast.vanity_domain),
        to: podcast.vanity_domain,
        rel: "external"
      )
    end
  end
end
