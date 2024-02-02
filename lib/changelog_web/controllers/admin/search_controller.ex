defmodule ChangelogWeb.Admin.SearchController do
  use ChangelogWeb, :controller

  alias Changelog.{Episode, NewsItem, NewsSource, Person, Podcast, Sponsor, Post, Topic}

  plug :assign_type when action in [:one]
  plug Authorize, [Policies.Admin.Search, :type]

  def all(conn, params = %{"q" => query}) do
    render(conn, with_format("all", params["f"]), %{
      results: %{
        episodes: search_episodes(query),
        news_items: search_news_items(query),
        news_sources: search_news_sources(query),
        people: search_people(query),
        podcasts: search_podcasts(query),
        posts: search_posts(query),
        sponsors: search_sponsors(query),
        topics: search_topics(query)
      },
      query: query
    })
  end

  def one(conn = %{assigns: %{type: type}}, params = %{"q" => query}) do
    results =
      case(type) do
        "episode" -> search_episodes(query)
        "news_item" -> search_news_items(query)
        "news_source" -> search_news_sources(query)
        "person" -> search_people(query)
        "podcast" -> search_podcasts(query)
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

  defp search_episodes(q) do
    from(q in Episode, where: ilike(q.title, ^"%#{q}%"))
    |> Episode.published()
    |> Episode.preload_podcast()
    |> Episode.preload_episode_request()
    |> Repo.all()
  end

  defp search_news_items(""), do: []

  defp search_news_items(q) do
    from(q in NewsItem, where: ilike(q.headline, ^"%#{q}%"))
    |> NewsItem.published()
    |> NewsItem.non_audio()
    |> NewsItem.non_post()
    |> Repo.all()
  end

  defp search_news_sources(""), do: []

  defp search_news_sources(q) do
    from(q in NewsSource, where: ilike(q.name, ^"%#{q}%"))
    |> Repo.all()
  end

  defp search_people(""), do: []

  defp search_people(q) do
    from(q in Person,
      where: ilike(q.name, ^"%#{q}%"),
      or_where: ilike(q.handle, ^"%#{q}%"),
      or_where: ilike(q.email, ^"%#{q}%")
    )
    |> Repo.all()
  end

  defp search_podcasts(""), do: []

  defp search_podcasts(q) do
    from(q in Podcast, where: ilike(q.name, ^"%#{q}%"))
    |> Repo.all()
  end

  defp search_posts(""), do: []

  defp search_posts(q) do
    from(q in Post, where: ilike(q.title, ^"%#{q}%"))
    |> Post.preload_author()
    |> Repo.all()
  end

  defp search_sponsors(""), do: []

  defp search_sponsors(q) do
    from(q in Sponsor, where: ilike(q.name, ^"%#{q}%"))
    |> Sponsor.preload_reps()
    |> Repo.all()
  end

  defp search_topics(""), do: []

  defp search_topics(q) do
    from(q in Topic,
      where: ilike(q.name, ^"%#{q}%"),
      or_where: ilike(q.slug, ^"%#{q}%")
    )
    |> Repo.all()
  end

  defp with_format(view_name, "json"), do: "#{view_name}.json"
  defp with_format(view_name, _other), do: "#{view_name}.html"
end
