defmodule ChangelogWeb.Xml.Sitemap do
  use ChangelogWeb, :verified_routes

  alias Changelog.{Album, Episode, NewsItem, NewsSource, Person, Podcast, Post, Topic, Repo}

  @doc """
  Returns a full XML document structure ready to be sent to Xml.generate/1
  """
  def document do
    {
      :urlset,
      [xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9"],
      urls()
    }
    |> XmlBuilder.document()
  end

  def urls do
    [
      loc(url(~p"/"), "always"),
      loc(url(~p"/about")),
      loc(url(~p"/coc")),
      loc(url(~p"/contact")),
      loc(url(~p"/films")),
      loc(url(~p"/community")),
      loc(url(~p"/sponsor")),
      loc(url(~p"/sponsor/pricing")),
      loc(url(~p"/nightly")),
      loc(url(~p"/join")),
      loc(url(~p"/subscribe")),
      loc(url(~p"/live")),
      loc(url(~p"/beats")),
      albums(),
      news_items(),
      loc(url(~p"/sources")),
      news_sources(),
      people(),
      loc(url(~p"/podcasts")),
      podcasts(),
      loc(url(~p"/request")),
      episodes(),
      loc(url(~p"/posts")),
      posts(),
      loc(url(~p"/topics")),
      topics()
    ]
    |> List.flatten()
  end

  def albums do
    albums = Album.all()

    Enum.map(albums, fn album ->
      loc(url(~p"/beats/#{album.slug}"))
    end)
  end

  def episodes do
    episodes =
      Episode.published()
      |> Episode.newest_first()
      |> Episode.exclude_transcript()
      |> Episode.preload_podcast()
      |> Repo.all()

    Enum.map(episodes, fn episode ->
      loc(url(~p"/#{episode.podcast.slug}/#{episode.slug}"))
    end)
  end

  def news_items do
    news_items =
      NewsItem.published()
      |> NewsItem.newest_first()
      |> Repo.all()

    Enum.map(news_items, fn item ->
      loc(url(~p"/news/#{NewsItem.slug(item)}"))
    end)
  end

  def news_sources do
    news_sources = NewsSource |> Repo.all()

    Enum.map(news_sources, fn source ->
      loc(url(~p"/source/#{source.slug}"))
    end)
  end

  def people do
    people = Person.with_public_profile() |> Repo.all()

    Enum.map(people, fn person ->
      loc(url(~p"/person/#{person.handle}"))
    end)
  end

  def podcasts do
    podcasts =
      Podcast.public()
      |> Podcast.newest_first()
      |> Repo.all()
      |> Kernel.++([Podcast.master()])

    Enum.map(podcasts, fn podcast ->
      [
        loc(url(~p"/#{podcast.slug}")),
        loc(url(~p"/#{podcast.slug}/popular")),
        loc(url(~p"/#{podcast.slug}/recommended")),
        loc(url(~p"/request/#{podcast.slug}"))
      ]
    end)
  end

  def posts do
    posts =
      Post.published()
      |> Post.newest_first()
      |> Repo.all()

    Enum.map(posts, fn post ->
      loc(url(~p"/posts/#{post.slug}"))
    end)
  end

  def topics do
    topics =
      Topic.with_news_items()
      |> Repo.all()

    Enum.map(topics, fn topic ->
      loc(url(~p"/topic/#{topic.slug}"))
    end)
  end

  defp loc(path) do
    {:url, nil, [{:loc, nil, path}]}
  end

  defp loc(path, changefreq) do
    {:url, nil, [{:loc, nil, path}, {:changefreq, nil, changefreq}]}
  end
end
