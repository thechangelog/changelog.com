defmodule ChangelogWeb.Admin.SearchController do
  use ChangelogWeb, :controller

  alias Changelog.{Faker, Episode, NewsItem, NewsSource, Person, Sponsor, Post, Topic}

  plug :assign_type when action in [:one]
  plug Authorize, [Policies.Search, :type]

  def all(conn, params = %{"q" => query}) do
    render(conn, with_format("all", params["f"]), %{
      results: %{
        episodes: search_episodes(query),
        news_items: search_news_items(query),
        news_sources: search_news_sources(query),
        people: search_people(query),
        posts: search_posts(query),
        sponsors: search_sponsors(query),
        topics: search_topics(query)
      },
      query: query
    })
  end

  def one(conn = %{assigns: %{type: type}}, params = %{"q" => query}) do
    results = case(type) do
      "episode" -> search_episodes(query)
      "news_item" -> search_news_items(query)
      "news_source" -> search_news_sources(query)
      "person" -> search_people(query)
      "post" -> search_posts(query)
      "sponsor" -> search_sponsors(query)
      "topic" -> search_topics(query)
    end

    render(conn, with_format(type, params["f"]), %{results: results, query: query})
  end

  defp assign_type(conn = %{params: %{"type" => type}}, _) do
    assign(conn, :type, type)
  end

  defp search_episodes(""), do: []
  defp search_episodes(q),  do: Repo.all(Episode.published(from q in Episode, where: ilike(q.title, ^"%#{q}%"))) |> Repo.preload(:podcast)

  defp search_news_items(""), do: []
  defp search_news_items(q),  do: Repo.all(NewsItem.published(from q in NewsItem, where: ilike(q.headline, ^"%#{q}%")))

  defp search_news_sources(""), do: []
  defp search_news_sources(q),  do: Repo.all(from q in NewsSource, where: ilike(q.name, ^"%#{q}%"))

  defp search_people(""), do: []
  defp search_people(q) do
    from(q in Person, where: ilike(q.name, ^"%#{q}%"), or_where: ilike(q.handle, ^"%#{q}%"), or_where: ilike(q.email, ^"%#{q}%"))
    |> Repo.all()
    |> Enum.reject(fn(p) -> Enum.member?(Faker.names(), p.name) end)
  end

  defp search_posts(""), do: []
  defp search_posts(q),  do: Repo.all(from q in Post, where: ilike(q.title, ^"%#{q}%")) |> Repo.preload(:author)

  defp search_sponsors(""), do: []
  defp search_sponsors(q),  do: Repo.all(from q in Sponsor, where: ilike(q.name, ^"%#{q}%"))

  defp search_topics(""), do: []
  defp search_topics(q),  do: Repo.all(from q in Topic, where: ilike(q.name, ^"%#{q}%"), or_where: ilike(q.slug, ^"%#{q}%"))

  defp with_format(view_name, "json"), do: "#{view_name}.json"
  defp with_format(view_name, _other), do: "#{view_name}.html"
end
