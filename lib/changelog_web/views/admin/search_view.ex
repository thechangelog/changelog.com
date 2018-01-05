defmodule ChangelogWeb.Admin.SearchView do
  use ChangelogWeb, :admin_view

  alias Changelog.{EpisodeSponsor, NewsItem, Repo}
  alias ChangelogWeb.Endpoint
  alias ChangelogWeb.Admin.{TopicView, EpisodeView, NewsItemView, NewsSourceView,
                            PersonView, PostView, SponsorView}

  @limit 3

  def render("all.json", _params = %{results: results, query: query}) do
    response = %{results: %{
      topics: %{name: "Topics", results: process_results(results.topics, &topic_result/1)},
      episodes: %{name: "Episodes", results: process_results(results.episodes, &episode_result/1)},
      news_items: %{name: "News", results: process_results(results.news_items, &news_item_result/1)},
      news_sources: %{name: "Sources", results: process_results(results.news_sources, &news_source_result/1)},
      people: %{name: "People", results: process_results(results.people, &person_result/1)},
      posts: %{name: "Posts", results: process_results(results.posts, &post_result/1)},
      sponsors: %{name: "Sponsors", results: process_results(results.sponsors, &sponsor_result/1)}}}

    counts = Enum.map(results, fn({_type, results}) -> Enum.count(results) end)
    if Enum.any?(counts, fn(count) -> count > @limit end) do
      Map.put(response, :action, %{url: "/admin/search?q=#{query}", text: "View all #{Enum.sum(counts)} results"})
    else
      response
    end
  end

  def render("topic.json", _params = %{results: results, query: _query}) do
    %{results: Enum.map(results, &topic_result/1)}
  end

  def render("news_item.json", _params = %{results: results, query: _query}) do
    %{results: Enum.map(results, &news_item_result/1)}
  end

  def render("news_source.json", _params = %{results: results, query: _query}) do
    %{results: Enum.map(results, &news_source_result/1)}
  end

  def render("person.json", _params = %{results: results, query: _query}) do
    %{results: Enum.map(results, &person_result/1)}
  end

  def render("sponsor.json", _params = %{results: results, query: _query}) do
    %{results: Enum.map(results, &sponsor_result/1)}
  end

  defp process_results(records, processFn) do
    records
    |> Enum.take(@limit)
    |> Enum.map(processFn)
  end

  defp topic_result(topic) do
    %{id: topic.id,
      title: topic.name,
      image: TopicView.icon_url(topic),
      url: admin_topic_path(Endpoint, :edit, topic.slug)}
  end

  defp news_item_result(news_item) do
    %{id: news_item.id,
      title: news_item.headline,
      url: admin_news_item_path(Endpoint, :edit, news_item)}
  end

  defp news_source_result(news_source) do
    %{id: news_source.id,
      title: news_source.name,
      image: NewsSourceView.icon_url(news_source),
      url: admin_news_source_path(Endpoint, :edit, news_source)}
  end

  defp episode_result(episode) do
    %{id: episode.id,
      title: EpisodeView.numbered_title(episode),
      url: admin_podcast_episode_path(Endpoint, :show, episode.podcast.slug, episode.slug)}
  end

  defp person_result(person) do
    %{id: person.id,
      title: person.name,
      description: "(@#{person.handle})",
      image: PersonView.avatar_url(person),
      url: admin_person_path(Endpoint, :edit, person)}
  end

  defp post_result(post) do
    %{title: post.title, url: admin_post_path(Endpoint, :edit, post)}
  end

  defp sponsor_result(sponsor) do
    latest =
      sponsor
      |> Ecto.assoc(:episode_sponsors)
      |> EpisodeSponsor.newest_first
      |> Ecto.Query.first
      |> Repo.one

    extras = if latest do
       %{title: latest.title,
         link_url: latest.link_url,
         description: latest.description}
    else
      %{title: sponsor.name,
        link_url: sponsor.website,
        description: sponsor.description}
    end

    %{id: sponsor.id,
      title: sponsor.name,
      description: sponsor.description,
      image: SponsorView.logo_url(sponsor, :color_logo, :small),
      url: admin_sponsor_path(Endpoint, :edit, sponsor),
      extras: extras}
  end
end
