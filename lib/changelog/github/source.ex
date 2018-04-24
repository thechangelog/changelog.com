defmodule Changelog.Github.Source do
  alias ChangelogWeb.PodcastView

  defstruct org: "thechangelog", repo: "", path: "", repo_url: "", html_url: "", raw_url: ""

  @org "thechangelog"
  @html_host "https://github.com"
  @raw_host "https://raw.githubusercontent.com"
  @repos ~w(show-notes transcripts)

  def repo_regex, do: ~r/\A(?<org>#{@org})\/(?<repo>#{Enum.join(@repos, "|")})\z/

  def new(repo, episode) do
    %__MODULE__{
      org: @org,
      repo: repo,
      path: path(episode),
      repo_url: [@html_host, @org, repo] |> Enum.join("/"),
      html_url: [@html_host, @org, repo, "blob", "master", path(episode)] |> Enum.join("/"),
      raw_url: [@raw_host, @org, repo, "master", path(episode)] |> Enum.join("/")
    }
  end

  defp path(episode) do
    podcast_name = PodcastView.dasherized_name(episode.podcast)
    podcast_slug = episode.podcast.slug
    episode_slug = episode.slug

    "#{podcast_slug}/#{podcast_name}-#{episode_slug}.md"
  end
end
