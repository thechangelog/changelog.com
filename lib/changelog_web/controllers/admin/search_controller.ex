defmodule ChangelogWeb.Admin.SearchController do
  use ChangelogWeb, :controller

  alias Changelog.{Topic, Episode, NewsSource, Person, Sponsor, Post}

  def all(conn, params = %{"q" => query}) do
    render(conn, with_format("all", params["f"]), %{
      results: %{
        topics: topic_query(query),
        episodes: episode_query(query),
        news_sources: news_source_query(query),
        people: person_query(query),
        posts: post_query(query),
        sponsors: sponsor_query(query)
      },
      query: query
    })
  end

  def one(conn, params = %{"q" => query, "type" => type}) do
    results = case(type) do
      "topic" -> topic_query(query)
      "episode" -> episode_query(query)
      "news_source" -> news_source_query(query)
      "person" -> person_query(query)
      "post" -> post_query(query)
      "sponsor" -> sponsor_query(query)
    end

    render(conn, with_format(type, params["f"]), %{results: results, query: query})
  end

  defp topic_query(q),     do: Repo.all(from c in Topic, where: ilike(c.name, ^"%#{q}%"))
  defp episode_query(q),     do: Repo.all(from e in Episode, where: ilike(e.title, ^"%#{q}%")) |> Repo.preload(:podcast)
  defp news_source_query(q), do: Repo.all(from s in NewsSource, where: ilike(s.name, ^"%#{q}%"))
  defp person_query(q),      do: Repo.all(from p in Person, where: ilike(p.name, ^"%#{q}%"))
  defp post_query(q),        do: Repo.all(from p in Post, where: ilike(p.title, ^"%#{q}%")) |> Repo.preload(:author)
  defp sponsor_query(q),     do: Repo.all(from s in Sponsor, where: ilike(s.name, ^"%#{q}%"))

  defp with_format(view_name, "json"), do: "#{view_name}.json"
  defp with_format(view_name, _other), do: "#{view_name}.html"
end
