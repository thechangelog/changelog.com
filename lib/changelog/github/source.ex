defmodule Changelog.Github.Source do
  alias ChangelogWeb.PodcastView

  @html_host "https://github.com"
  @raw_host "https://raw.githubusercontent.com"

  def repo_name(repo), do: "thechangelog/#{repo}"
  def repo_url(repo), do: "#{@html_host}/#{repo_name(repo)}"
  def html_url(repo, episode), do: "#{@html_host}/#{repo_name(repo)}/blob/master/#{path(episode)}"
  def raw_url(repo, episode), do: "#{@raw_host}/#{repo_name(repo)}/master/#{path(episode)}"

  defp path(episode) do
    podcast_name = PodcastView.dasherized_name(episode.podcast)
    podcast_slug = episode.podcast.slug
    episode_slug = episode.slug

    "#{podcast_slug}/#{podcast_name}-#{episode_slug}.md"
  end
end
