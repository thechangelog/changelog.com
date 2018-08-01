defmodule ChangelogWeb.Admin.SearchController do
  use ChangelogWeb, :controller

  alias Changelog.{Topic, Episode, NewsItem, NewsSource, Person, Sponsor, Post}

  plug :assign_type when action in [:one]
  plug Authorize, [Policies.Search, :type]

  def all(conn, params = %{"q" => query}) do
    render(conn, with_format("all", params["f"]), %{
      results: %{
        topics: topic_query(query),
        episodes: episode_query(query),
        news_items: news_item_query(query),
        news_sources: news_source_query(query),
        people: person_query(query),
        posts: post_query(query),
        sponsors: sponsor_query(query)
      },
      query: query
    })
  end

  def one(conn = %{assigns: %{type: type}}, params = %{"q" => query}) do
    results = case(type) do
      "topic" -> topic_query(query)
      "episode" -> episode_query(query)
      "news_item" -> news_item_query(query)
      "news_source" -> news_source_query(query)
      "person" -> person_query(query)
      "post" -> post_query(query)
      "sponsor" -> sponsor_query(query)
    end

    render(conn, with_format(type, params["f"]), %{results: results, query: query})
  end

  defp assign_type(conn = %{params: %{"type" => type}}, _) do
    assign(conn, :type, type)
  end

  defp episode_query(q),     do: Repo.all(Episode.published(from q in Episode, where: ilike(q.title, ^"%#{q}%"))) |> Repo.preload(:podcast)
  defp news_item_query(q),   do: Repo.all(NewsItem.published(from q in NewsItem, where: ilike(q.headline, ^"%#{q}%")))
  defp news_source_query(q), do: Repo.all(from q in NewsSource, where: ilike(q.name, ^"%#{q}%"))
  defp person_query(q),      do: Repo.all(from q in Person, where: ilike(q.name, ^"%#{q}%"), or_where: ilike(q.handle, ^"%#{q}%"))
  defp post_query(q),        do: Repo.all(from q in Post, where: ilike(q.title, ^"%#{q}%")) |> Repo.preload(:author)
  defp sponsor_query(q),     do: Repo.all(from q in Sponsor, where: ilike(q.name, ^"%#{q}%"))
  defp topic_query(q),       do: Repo.all(from q in Topic, where: ilike(q.name, ^"%#{q}%"), or_where: ilike(q.slug, ^"%#{q}%"))

  defp with_format(view_name, "json"), do: "#{view_name}.json"
  defp with_format(view_name, _other), do: "#{view_name}.html"
end
