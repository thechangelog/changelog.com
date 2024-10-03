defmodule ChangelogWeb.FeedView do
  use ChangelogWeb, :public_view

  alias Changelog.{Episode, ListKit, NewsItem, Podcast, Post, StringKit}
  alias ChangelogWeb.{EpisodeView, NewsItemView}

  def discussion_link(nil), do: ""

  def discussion_link(episode = %Episode{}) do
    link = if episode.podcast.zulip_url do
      episode.podcast.zulip_url
    else
      url(~p"/#{episode.podcast.slug}/#{episode.slug}/discuss")
    end

    discussion_link(link)
  end

  def discussion_link(post = %Post{}), do: discussion_link(post.news_item)

  def discussion_link(item = %NewsItem{}) do
    url(~p"/news/#{NewsItemView.hashid(item)}") |> discussion_link()
  end

  def discussion_link(url) when is_binary(url) do
    content_tag(:p) do
      content_tag(:a, "Join the discussion", href: url)
    end
    |> safe_to_string()
  end

  def custom_episode_title(%{title_format: format}, episode) do
    case format do
      "" ->
        episode.title

      nil ->
        episode.title

      string ->
        episode_title = Map.get(episode, :title) || ""
        episode_subtitle = Map.get(episode, :subtitle) || ""
        episode_number = integer_slug(Map.get(episode, :slug, ""))
        podcast_name = get_in(episode, [Access.key!(:podcast), Access.key!(:name)]) || ""

        title = Regex.replace(~r/{title}/, string, episode_title)
        title = Regex.replace(~r/{subtitle}/, title, episode_subtitle)
        title = Regex.replace(~r/{number}/, title, episode_number)
        title = Regex.replace(~r/{podcast}/, title, podcast_name)

        title
    end
  end

  def custom_episode_title(_feed, episode), do: episode.title

  defp integer_slug(slug), do: if(StringKit.is_integer(slug), do: slug, else: "")

  def episode_title(%{slug: "master"}, episode), do: EpisodeView.title_with_podcast_aside(episode)

  def episode_title(%{slug: "podcast", is_meta: true}, episode) do
    aside =
      case episode.podcast.slug do
        "news" -> "News"
        "friends" -> "Friends"
        "podcast" -> "Interview"
      end

    "#{episode.title} (#{aside})"
  end

  def episode_title(_podcast, episode), do: episode.title

  def image_link(item = %NewsItem{}) do
    if link = NewsItemView.image_link(item), do: safe_to_string(link)
  end

  def podcast_full_description(%{description: description, extended_description: extended}) do
    [description, extended]
    |> ListKit.compact()
    |> Enum.map(&SharedHelpers.md_to_text/1)
    |> Enum.join(" ")
  end

  def podcast_name_with_metadata(%{slug: "podcast", is_meta: true, name: name}) do
    "#{name}: Software Development, Open Source"
  end

  def podcast_name_with_metadata(podcast) do
    case podcast.slug do
      "brainscience" -> "#{podcast.name}: Neuroscience, Behavior"
      "founderstalk" -> "#{podcast.name}: Startups, CEOs, Leadership"
      "gotime" -> "#{podcast.name}: Golang, Software Engineering"
      "jsparty" -> "#{podcast.name}: JavaScript, CSS, Web Development"
      "practicalai" -> "#{podcast.name}: Machine Learning, Data Science, LLM"
      "shipit" -> "#{podcast.name} Cloud, SRE, Platform Engineering"
      _else -> podcast.name
    end
  end

  def podcast_name_with_numbered_episode_title(episode) do
    numbered_title = EpisodeView.numbered_title(episode)
    "#{episode.podcast.name} #{numbered_title}"
  end

  # Exists to special-case /interviews
  def podcast_url(podcast) do
    slug = Podcast.slug_with_interviews_special_case(podcast)
    url(~p"/#{slug}")
  end

  def video_embed(item = %NewsItem{}) do
    if embed = NewsItemView.video_embed(item), do: safe_to_string(embed)
  end
end
