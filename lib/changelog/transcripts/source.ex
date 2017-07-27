defmodule Changelog.Transcripts.Source do
  @html_host "https://github.com"
  @raw_host "https://raw.githubusercontent.com"
  @repo_name "thechangelog/transcripts"

  def repo_name, do: @repo_name
  def repo_url, do: "#{@html_host}/#{@repo_name}"

  def html_url(episode) do
    "#{@html_host}/#{@repo_name}/blob/master/#{path(episode)}"
  end

  def raw_url(episode) do
    "#{@raw_host}/#{@repo_name}/master/#{path(episode)}"
  end

  defp path(episode) do
    podcast_name = Changelog.PodcastView.dasherized_name(episode.podcast)
    podcast_slug = episode.podcast.slug
    episode_slug = episode.slug

    "#{podcast_slug}/#{podcast_name}-#{episode_slug}.md"
  end
end
