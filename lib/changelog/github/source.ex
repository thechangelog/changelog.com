defmodule Changelog.Github.Source do
  alias ChangelogWeb.PodcastView

  @org "thechangelog"
  @html_host "https://github.com"
  @raw_host "https://raw.githubusercontent.com"
  @repos ~w(show-notes transcripts)

  def repo_regex, do: ~r/\A(?<org>#{@org})\/(?<repo>#{Enum.join(@repos, "|")})\z/
  def repo_url(repo), do: [@html_host, @org, repo] |> Enum.join("/")
  def html_url(repo, episode), do: [repo_url(repo), "blob", "master", path(episode)] |> Enum.join("/")
  def raw_url(repo, episode), do: [@raw_host, @org, repo, "master", path(episode)] |> Enum.join("/")

  defp path(episode) do
    podcast_name = PodcastView.dasherized_name(episode.podcast)
    podcast_slug = episode.podcast.slug
    episode_slug = episode.slug

    "#{podcast_slug}/#{podcast_name}-#{episode_slug}.md"
  end
end
