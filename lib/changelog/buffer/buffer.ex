defmodule Changelog.Buffer do
  alias Changelog.NewsItem
  alias Changelog.Buffer.{Client, Content}

  @afk ~w(5af9b7a28bae46d01ead92d3)
  @brainscience ~w(5d49c7410eb4bb4992040a42)
  @changelog ~w(4f3ad7c8512f7ef962000004)
  @founderstalk ~w(5b23f65f772894a723424ec5)
  @gotime ~w(5734d7fc1b14578733224a70)
  @jsparty ~w(58b47fd78d23761f5f19ca89)
  @practicalai ~w(5ac3c64b3fda312b116ca788)
  @shipit ~w(60c8d806bcbd6083a38beb28)

  @topics %{
    @founderstalk => ~w(startups leadership product-development vc),
    @gotime => ~w(go),
    @brainscience => ~w(brain-science mental-health),
    @jsparty => ~w(javascript node html css npm),
    @practicalai => ~w(ai datascience machinelearning deeplearning nlp),
    @shipit => ~w(ops kubernetes aws cicd cloud servers serverless)
  }

  # this returns a single profile, but they're stored as lists so it actually
  # returns a list of one
  def profiles_for_podcast(%{slug: slug}) do
    cond do
      String.starts_with?(slug, "afk") -> @afk
      String.starts_with?(slug, "brainscience") -> @brainscience
      String.starts_with?(slug, "founderstalk") -> @founderstalk
      String.starts_with?(slug, "gotime") -> @gotime
      String.starts_with?(slug, "jsparty") -> @jsparty
      String.starts_with?(slug, "news") -> nil
      String.starts_with?(slug, "practicalai") -> @practicalai
      String.starts_with?(slug, "shipit") -> @shipit
      true -> @changelog
    end
  end

  # this can return multiple profile lists if they all match the given topics
  # so we flatten them at the end to make one final list
  def profiles_for_topics(topics) do
    slugs = Enum.map(topics, & &1.slug)

    @topics
    |> Enum.filter(fn {_profile_list, topic_list} ->
      Enum.any?(slugs, fn slug -> slug in topic_list end)
    end)
    |> Enum.map(fn {profile_list, _topic_list} -> profile_list end)
    |> List.flatten()
  end

  def queue(item) do
    item
    |> NewsItem.preload_all()
    |> NewsItem.load_object()
    |> queue_item()
  end

  # a feed-only news item
  defp queue_item(%NewsItem{feed_only: true}), do: false
  # an episode news item
  defp queue_item(item = %NewsItem{type: :audio, object: episode}) when is_map(episode) do
    link = Content.episode_link(item)
    text = Content.episode_text(item)
    profiles = profiles_for_podcast(episode.podcast)
    Client.create(profiles, text, link: link)
  end

  # an episode news item with no attached object
  defp queue_item(%NewsItem{type: :audio}), do: false
  defp queue_item(%NewsItem{type: :audio, object: nil}), do: false
  # a post news item
  defp queue_item(item = %NewsItem{object: post}) when is_map(post) do
    brief = Content.post_brief(item)
    text = Content.post_text(item)
    link = Content.post_link(item)

    # network-wide gets full text
    Client.create(@changelog, text, link: link)

    # topic-specific profiles get brief version
    for profile <- profiles_for_topics(item.topics) do
      Client.create(profile, brief, link: link)
    end
  end

  # all other 'normal' news items
  defp queue_item(item = %NewsItem{}) do
    image = Content.news_item_image(item)
    text = Content.news_item_text(item)
    brief = Content.news_item_brief(item)
    link = Content.news_item_link(item)

    # network-wide gets full text
    Client.create(@changelog, text, link: link, photo: image)

    # topic-specific profiles get brief version
    for profile <- profiles_for_topics(item.topics) do
      Client.create(profile, brief, link: link, photo: image)
    end
  end
end
