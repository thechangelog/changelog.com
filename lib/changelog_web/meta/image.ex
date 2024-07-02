defmodule ChangelogWeb.Meta.Image do
  use ChangelogWeb, :verified_routes

  alias Changelog.Snap

  alias ChangelogWeb.{
    AlbumView,
    Endpoint,
    EpisodeView,
    Meta,
    NewsItemView,
    NewsSourceView,
    PageView,
    PersonView,
    PodcastView,
    PostView,
    TopicView
  }

  def get(conn) do
    assigns = Meta.prep_assigns(conn)
    get_image(assigns)
  end

  # the podcasts index
  defp get_image(%{view_module: PodcastView, view_template: "index.html"}), do: podcasts_image()
  # the main index page
  defp get_image(%{view_module: PageView, view_template: "index.html"}), do: podcasts_image()

  # a specific podcast episode
  defp get_image(%{view_module: EpisodeView, podcast: podcast, episode: episode}),
    do: episode_image(podcast, episode)

  # a specific podcast
  defp get_image(%{podcast: podcast}), do: podcast_image(podcast)

  # a specific news item with an image
  defp get_image(%{view_module: NewsItemView, item: item = %{image: img}}) when is_map(img),
    do: NewsItemView.image_url(item, :original)

  # a specific news item without an image
  defp get_image(%{view_module: NewsItemView, item: item}) do
    cond do
      item.author -> person_image(item.author)
      item.source && item.source.icon -> source_image(item.source)
      topic = Enum.find(item.topics, & &1.icon) -> topic_image(topic)
      true -> item_type_image(item)
    end
  end

  # all album pages
  defp get_image(%{view_module: AlbumView}) do
    static_image(~w[images share changelog-beats.jpg])
  end

  # a specific post
  defp get_image(%{view_module: PostView, post: post}) do
    cond do
      post.image -> post_image(post)
      post.author -> person_image(post.author)
      true -> summary_image()
    end
  end

  # a specific news source
  defp get_image(%{view_module: NewsSourceView, source: source}) when is_map(source),
    do: source_image(source)

  # a specific person's profile
  defp get_image(%{view_module: PersonView, person: person}) when is_map(person),
    do: person_image(person)

  # a specific topic
  defp get_image(%{view_module: TopicView, topic: topic}) when is_map(topic),
    do: topic_image(topic)

  # special image for /ten
  defp get_image(%{view_module: PageView, view_template: "ten.html"}),
    do: static_image(~w[images content ten ten-year-social.jpg])

  # fallback
  defp get_image(_), do: summary_image()

  # convenience functions
  defp item_type_image(item), do: static_image(~w[images defaults type-#{item.type}.png])
  defp person_image(person), do: PersonView.avatar_url(person, :large)
  defp podcast_image(podcast), do: static_image(~w[images share twitter-#{podcast.slug}.png])
  defp podcasts_image, do: static_image(~w[images share all-podcasts.png])

  defp episode_image(podcast, episode), do: Snap.img_url(podcast, episode)

  defp post_image(post), do: PostView.image_url(post, :large)
  defp source_image(source), do: NewsSourceView.icon_url(source, :large)
  defp static_image(parts), do: static_url(Endpoint, ~p"/#{parts}")
  defp topic_image(topic), do: TopicView.icon_url(topic, :large)

  defp summary_image, do: static_image(~w[images share twitter-sidewide-summary.png])
end
