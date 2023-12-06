defmodule ChangelogWeb.Admin.NewsItemControllerTest do
  use ChangelogWeb.ConnCase

  import Mock

  alias Changelog.{Buffer, NewsItem, NewsQueue, Typesense}

  @valid_attrs %{
    type: :project,
    headline: "Ruby on Rails",
    url: "https://rubyonrails.org",
    logger_id: 1
  }
  @invalid_attrs %{type: :project, headline: "Ruby on Rails", url: ""}

  @tag :as_inserted_admin
  test "lists all published news items", %{conn: conn} do
    i1 = insert(:published_news_item)
    i2 = insert(:news_item)

    conn = get(conn, Routes.admin_news_item_path(conn, :index))

    assert html_response(conn, 200) =~ ~r/News/
    assert String.contains?(conn.resp_body, i1.headline)
    refute String.contains?(conn.resp_body, i2.headline)
  end

  @tag :as_admin
  test "renders form to create new item", %{conn: conn} do
    conn = get(conn, Routes.admin_news_item_path(conn, :new))
    assert html_response(conn, 200) =~ ~r/new/
  end

  @tag :as_admin
  test "creates news item and leaves it as draft", %{conn: conn} do
    logger = insert(:person)

    conn =
      post(conn, Routes.admin_news_item_path(conn, :create),
        news_item: %{@valid_attrs | logger_id: logger.id},
        queue: "draft"
      )

    drafted = Repo.one(NewsItem.limit(1))
    assert redirected_to(conn) == Routes.admin_news_item_path(conn, :edit, drafted)
    assert count(NewsItem.drafted()) == 1
    assert count(NewsItem.published()) == 0
    assert count(NewsQueue) == 0
  end

  @tag :as_admin
  test "creates news item and publishes immediately", %{conn: conn} do
    logger = insert(:person)

    with_mocks([
      {Buffer, [], [queue: fn _ -> true end]},
      {Typesense.Client, [], [upsert_documents: fn _, _ -> {:ok, %HTTPoison.Response{body: "{}"}} end]},
    ]) do
      conn =
        post(conn, Routes.admin_news_item_path(conn, :create),
          news_item: %{@valid_attrs | logger_id: logger.id},
          queue: "publish"
        )

      assert redirected_to(conn) == Routes.admin_news_item_path(conn, :index)
      assert count(NewsItem.published()) == 1
      wait_for_passing(1000, fn -> assert called(Typesense.Client.upsert_documents(:_, :_)) end)
    end
  end

  @tag :as_admin
  test "creates news item and queues it", %{conn: conn} do
    logger = insert(:person)

    conn =
      post(conn, Routes.admin_news_item_path(conn, :create),
        news_item: %{@valid_attrs | logger_id: logger.id},
        queue: "append"
      )

    assert redirected_to(conn) == Routes.admin_news_item_path(conn, :index)
    assert count(NewsItem) == 1
    assert count(NewsItem.published()) == 0
    assert count(NewsQueue) == 1
  end

  @tag :as_admin
  test "does not create with invalid attributes", %{conn: conn} do
    count_before = count(NewsItem)
    conn = post(conn, Routes.admin_news_item_path(conn, :create), news_item: @invalid_attrs)

    assert html_response(conn, 200) =~ ~r/error/
    assert count(NewsItem) == count_before
  end

  @tag :as_admin
  test "renders form to edit news item", %{conn: conn} do
    news_item = insert(:news_item)

    conn = get(conn, Routes.admin_news_item_path(conn, :edit, news_item))
    assert html_response(conn, 200) =~ ~r/edit/i
  end

  @tag :as_admin
  test "updates news item and redirects", %{conn: conn} do
    logger = insert(:person)
    news_item = insert(:news_item, logger: logger)

    conn =
      put(conn, Routes.admin_news_item_path(conn, :update, news_item.id),
        news_item: %{@valid_attrs | logger_id: logger.id},
        next: Routes.admin_news_item_path(conn, :index)
      )

    assert redirected_to(conn) == Routes.admin_news_item_path(conn, :index)
    assert count(NewsItem) == 1
  end

  @tag :as_admin
  test "updates draft news item, queues it, and redirects", %{conn: conn} do
    logger = insert(:person)
    news_item = insert(:news_item, logger: logger)

    conn =
      put(conn, Routes.admin_news_item_path(conn, :update, news_item.id),
        news_item: %{@valid_attrs | logger_id: logger.id},
        queue: "append"
      )

    assert redirected_to(conn) == Routes.admin_news_item_path(conn, :index)
    assert count(NewsItem) == 1
    assert count(NewsItem.published()) == 0
    assert count(NewsItem.drafted()) == 0
    assert count(NewsQueue) == 1
  end

  @tag :as_admin
  test "does not update with invalid attributes", %{conn: conn} do
    news_item = insert(:news_item)
    count_before = count(NewsItem)

    conn =
      put(conn, Routes.admin_news_item_path(conn, :update, news_item.id),
        news_item: @invalid_attrs
      )

    assert html_response(conn, 200) =~ ~r/error/
    assert count(NewsItem) == count_before
  end

  @tag :as_admin
  test "deletes a news item and redirects", %{conn: conn} do
    news_item = insert(:news_item)

    conn = delete(conn, Routes.admin_news_item_path(conn, :delete, news_item.id))

    assert redirected_to(conn) == Routes.admin_news_item_path(conn, :index)
    assert count(NewsItem) == 0
  end

  @tag :as_admin
  test "unpublishes a news item", %{conn: conn} do
    news_item = insert(:published_news_item)
    assert count(NewsItem.published()) == 1

    with_mocks([
      {Typesense.Client, [], delete_document: fn _, _ -> {:ok, %{}} end}
    ]) do
      conn = post(conn, Routes.admin_news_item_path(conn, :unpublish, news_item))

      assert redirected_to(conn) == Routes.admin_news_item_path(conn, :index)
      assert count(NewsItem.published()) == 0
      assert count(NewsItem.drafted()) == 1
      wait_for_passing(1000, fn -> assert called(Typesense.Client.delete_document(:_, news_item.id)) end)
    end
  end

  @tag :as_admin
  test "declines a news item and redirects", %{conn: conn} do
    news_item = insert(:news_item)

    conn = delete(conn, Routes.admin_news_item_path(conn, :decline, news_item.id))

    assert redirected_to(conn) == Routes.admin_news_item_path(conn, :index)
    assert count(NewsItem) == 1
    assert count(NewsItem.declined()) == 1
  end

  @tag :as_admin
  test "declines a news item with a message and redirects", %{conn: conn} do
    news_item = insert(:news_item)

    conn =
      delete(conn, Routes.admin_news_item_path(conn, :decline, news_item.id), %{
        "message" => "declined because reason"
      })

    assert redirected_to(conn) == Routes.admin_news_item_path(conn, :index)
    assert count(NewsItem) == 1
    assert count(NewsItem.declined()) == 1

    assert %{message: "declined because reason", status: :declined} =
             Changelog.Repo.get(NewsItem, news_item.id, [])
  end

  test "requires user auth on all actions", %{conn: conn} do
    news_item = insert(:news_item)

    Enum.each(
      [
        get(conn, Routes.admin_news_item_path(conn, :index)),
        get(conn, Routes.admin_news_item_path(conn, :new)),
        post(conn, Routes.admin_news_item_path(conn, :create), news_item: @valid_attrs),
        get(conn, Routes.admin_news_item_path(conn, :edit, news_item.id)),
        put(conn, Routes.admin_news_item_path(conn, :update, news_item.id),
          news_item: @valid_attrs
        ),
        delete(conn, Routes.admin_news_item_path(conn, :delete, news_item.id)),
        delete(conn, Routes.admin_news_item_path(conn, :decline, news_item.id))
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end
    )
  end
end
