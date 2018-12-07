defmodule Changelog.Github.Source do
  alias Changelog.StringKit

  defstruct [:org, :repo, :path, :name, :repo_url, :html_url, :raw_url]

  @org "thechangelog"
  @html_host "https://github.com"
  @raw_host "https://raw.githubusercontent.com"
  @repos ~w(show-notes transcripts)

  def repo_regex, do: ~r/\A(?<org>#{@org})\/(?<repo>#{Enum.join(@repos, "|")})\z/

  def new(repo, episode) do
    %__MODULE__{
      org: @org,
      repo: repo,
      name: name(episode),
      path: path(episode),
      repo_url: joined([@html_host, @org, repo]),
      html_url: joined([@html_host, @org, repo, "blob", "master", path(episode)]),
      raw_url: joined([@raw_host, @org, repo, "master", path(episode)])
    }
  end

  defp joined(list), do: Enum.join(list, "/")

  defp name(episode), do: "#{episode.podcast.name} ##{episode.slug}"

  defp path(episode) do
    podcast_name = StringKit.dasherize(episode.podcast.name)
    podcast_slug = episode.podcast.slug
    episode_slug = episode.slug

    "#{podcast_slug}/#{podcast_name}-#{episode_slug}.md"
  end
end
