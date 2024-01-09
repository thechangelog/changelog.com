defmodule ChangelogWeb.NewsItemControllerTest do
  use ChangelogWeb.ConnCase

  alias Changelog.{NewsItem, NewsQueue, Post, Subscription}

  test "getting a published news item page via hashid", %{conn: conn} do
    item = insert(:published_news_item, headline: "Hash ID me!")
    conn = get(conn, Routes.news_item_path(conn, :show, NewsItem.hashid(item)))
    assert redirected_to(conn) == Routes.news_item_path(conn, :show, NewsItem.slug(item))
  end

  test "getting a published news item page via full slug", %{conn: conn} do
    item = insert(:published_news_item, headline: "You gonna like this")
    conn = get(conn, Routes.news_item_path(conn, :show, NewsItem.slug(item)))
    assert html_response(conn, 200) =~ item.headline
  end

  test "getting a published news item page that has a post", %{conn: conn} do
    post = insert(:published_post)
    item = post |> post_news_item() |> insert()
    conn = get(conn, Routes.news_item_path(conn, :show, Post.hashid(item)))
    assert redirected_to(conn) == Routes.post_path(conn, :show, post.slug)
  end

  test "getting an unpublished news item page", %{conn: conn} do
    item = insert(:news_item)

    assert_raise Ecto.NoResultsError, fn ->
      get(conn, Routes.news_item_path(conn, :show, NewsItem.slug(item)))
    end
  end

  test "geting a news item page that doesn't exist", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get(conn, Routes.news_item_path(conn, :show, "bad-news_item"))
    end
  end

  test "posting to the visit endpoint tracks and responds with 204", %{conn: conn} do
    item = insert(:published_news_item, headline: "You gonna like this")
    conn = post(conn, Routes.news_item_path(conn, :visit, NewsItem.hashid(item)))
    assert conn.status == 204
    item = Repo.get(NewsItem, item.id)
    assert item.click_count == 1
  end

  test "getting the visit endpoint sans internal object uses html redirect", %{conn: conn} do
    item = insert(:published_news_item, headline: "You gonna like this")
    conn = get(conn, Routes.news_item_path(conn, :visit, NewsItem.hashid(item)))
    assert html_response(conn, 200) =~ item.url
    item = Repo.get(NewsItem, item.id)
    assert item.click_count == 1
  end

  test "getting the visit endpoint with internal object uses http redirect", %{conn: conn} do
    podcast = insert(:podcast, slug: "ohai")
    episode = insert(:published_episode, podcast: podcast, slug: "okbai")
    item = episode |> episode_news_item() |> insert()
    conn = get(conn, Routes.news_item_path(conn, :visit, NewsItem.hashid(item)))
    assert redirected_to(conn) == "/ohai/okbai"
    item = Repo.get(NewsItem, item.id)
    assert item.click_count == 1
  end

  @tag :as_admin
  test "getting the visit endpoint as admin does not visit", %{conn: conn} do
    item = insert(:published_news_item, headline: "You gonna like this")
    conn = get(conn, Routes.news_item_path(conn, :visit, NewsItem.hashid(item)))
    assert html_response(conn, 200) =~ item.url
    item = Repo.get(NewsItem, item.id)
    assert item.click_count == 0
  end

  test "hitting the impress endpoint", %{conn: conn} do
    item1 = insert(:published_news_item, headline: "You gonna like this")
    item2 = insert(:published_news_item, headline: "You gonna like this too")

    conn =
      post(conn, Routes.news_item_path(conn, :impress),
        ids: "#{NewsItem.hashid(item1)},#{NewsItem.hashid(item2)}"
      )

    assert conn.status == 204
    item1 = Repo.get(NewsItem, item1.id)
    item2 = Repo.get(NewsItem, item2.id)
    assert item1.impression_count == 1
    assert item2.impression_count == 1
  end

  @tag :as_admin
  test "hitting the impress endpoint as admin does not impress", %{conn: conn} do
    item = insert(:published_news_item, headline: "You gonna like this")
    conn = post(conn, Routes.news_item_path(conn, :impress), ids: "#{NewsItem.hashid(item)}")
    assert conn.status == 204
    item = Repo.get(NewsItem, item.id)
    assert item.impression_count == 0
  end

  test "renders the form to submit news", %{conn: conn} do
    conn = get(conn, Routes.news_item_path(conn, :new))
    assert html_response(conn, 200) =~ ~r/submit/
  end

  test "does not create with no user", %{conn: conn} do
    count_before = count(NewsItem)

    conn =
      post(conn, Routes.news_item_path(conn, :create),
        news_item: %{url: "https://ohai.me/x", headline: "dig it?"}
      )

    assert redirected_to(conn) == Routes.sign_in_path(conn, :new)
    assert count(NewsItem) == count_before
  end

  @tag :as_inserted_user
  test "does not create when user is not subscribed to News", %{conn: conn} do
    count_before = count(NewsItem)

    conn =
      post(conn, Routes.news_item_path(conn, :create),
        news_item: %{url: "https://ohai.me/x", headline: "dig it?"})

    assert html_response(conn, 200) =~ ~r/error/
    assert count(NewsItem) == count_before
  end

  @tag :as_inserted_user
  test "creates news item and sets it as submitted", %{conn: conn} do
    update = insert(:podcast, slug: "news")
    insert(:subscription_on_podcast, podcast: update, person: conn.assigns.current_user)

    conn =
      post(conn, Routes.news_item_path(conn, :create),
        news_item: %{url: "https://ohai.me/x", headline: "dig it?"})

    assert redirected_to(conn) == Routes.root_path(conn, :index)
    assert count(NewsItem.submitted()) == 1
    assert count(NewsItem.published()) == 0
    assert count(NewsQueue) == 0
  end

  @tag :as_inserted_user
  test "does not create with invalid attributes", %{conn: conn} do
    count_before = count(NewsItem)

    conn =
      post(conn, Routes.news_item_path(conn, :create), news_item: %{url: "https://just.this"})

    assert html_response(conn, 200) =~ ~r/error/
    assert count(NewsItem) == count_before
  end

  test "cannot subscribe with no user", %{conn: conn} do
    item = insert(:published_news_item)
    conn = get(conn, Routes.news_item_path(conn, :subscribe, NewsItem.hashid(item)))

    assert redirected_to(conn) == Routes.sign_in_path(conn, :new)
  end

  @tag :as_inserted_user
  test "subscribes and redirects back to news item", %{conn: conn} do
    item = insert(:published_news_item)
    conn = get(conn, Routes.news_item_path(conn, :subscribe, NewsItem.hashid(item)))

    assert redirected_to(conn) == Routes.news_item_path(conn, :show, NewsItem.slug(item))
    assert count(Subscription.subscribed()) == 1
  end

  test "cannot unsubscribe with no user", %{conn: conn} do
    item = insert(:published_news_item)
    conn = get(conn, Routes.news_item_path(conn, :unsubscribe, NewsItem.hashid(item)))

    assert redirected_to(conn) == Routes.sign_in_path(conn, :new)
  end

  @tag :as_inserted_user
  test "unsubscribes and redirects back to news item", %{conn: conn} do
    item = insert(:published_news_item)
    conn = get(conn, Routes.news_item_path(conn, :unsubscribe, NewsItem.hashid(item)))

    assert redirected_to(conn) == Routes.news_item_path(conn, :show, NewsItem.slug(item))
    assert count(Subscription.subscribed()) == 0
    assert count(Subscription.unsubscribed()) == 1
  end
end
