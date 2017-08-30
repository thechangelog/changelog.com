defmodule ChangelogWeb.Admin.SearchController do
  use ChangelogWeb, :controller

  alias Changelog.{Channel, Episode, Person, Sponsor, Post}

  def all(conn, params = %{"q" => query}) do
    render conn, with_format("all", params["f"]), %{
      results: %{
        channels: channel_query(query),
        episodes: episode_query(query),
        people: person_query(query),
        posts: post_query(query),
        sponsors: sponsor_query(query)
      },
      query: query
    }
  end

  def channel(conn, params = %{"q" => query}) do
    render conn, with_format("channel", params["f"]), %{
      results: channel_query(query),
      query: query
    }
  end

  def person(conn, params = %{"q" => query}) do
    render conn, with_format("person", params["f"]), %{
      results: person_query(query),
      query: query
    }
  end

  def post(conn, params = %{"q" => query}) do
    render conn, with_format("post", params["f"]), %{
      results: post_query(query),
      query: query
    }
  end

  def sponsor(conn, params = %{"q" => query}) do
    render conn, with_format("sponsor", params["f"]), %{
      results: sponsor_query(query),
      query: query
    }
  end

  defp channel_query(q) do
    Repo.all(from c in Channel, where: ilike(c.name, ^"%#{q}%"))
  end
  defp episode_query(q) do
    Repo.all(from e in Episode, where: ilike(e.title, ^"%#{q}%"))
    |> Repo.preload(:podcast)
  end
  defp person_query(q) do
    Repo.all(from p in Person, where: ilike(p.name, ^"%#{q}%"))
  end
  defp post_query(q) do
    Repo.all(from p in Post, where: ilike(p.title, ^"%#{q}%"))
    |> Repo.preload(:author)
  end

  defp sponsor_query(q) do
    Repo.all(from s in Sponsor, where: ilike(s.name, ^"%#{q}%"))
  end

  defp with_format(view_name, "json"), do: "#{view_name}.json"
  defp with_format(view_name, _other), do: "#{view_name}.html"
end
