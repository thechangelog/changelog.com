defmodule ChangelogWeb.Admin.PodcastView do
  use ChangelogWeb, :admin_view

  alias Changelog.{EpisodeStat, Podcast, Repo, Topic}
  alias ChangelogWeb.PodcastView

  def episode_count(podcast), do: PodcastView.episode_count(podcast)
  def download_count(podcast), do: podcast.download_count |> round |> comma_separated
  def reach_count(podcast) do
    if podcast.reach_count > podcast.download_count do
      comma_separated(podcast.reach_count)
    else
      download_count(podcast)
    end
  end

  def last_stat(podcast) do
    podcast
      |> EpisodeStat.with_podcast
      |> EpisodeStat.newest_first
      |> EpisodeStat.limit(1)
      |> Repo.one
  end

  def position_options do
    count = Podcast.ours |> Podcast.not_retired |> Repo.count
    1..count
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
    |> Enum.map(fn({k, _v}) -> {String.capitalize(Atom.to_string(k)), k} end)
  end

  def vanity_link(podcast) do
    if podcast.vanity_domain do
      external_link(domain_name(podcast.vanity_domain), to: podcast.vanity_domain)
    end
  end
end
