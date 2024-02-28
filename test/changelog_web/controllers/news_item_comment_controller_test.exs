defmodule ChangelogWeb.NewsItemCommentControllerTest do
  use ChangelogWeb.ConnCase
  use Oban.Testing, repo: Changelog.Repo

  import Mock

  alias Changelog.{NewsItemComment, Notifier}
  alias Changelog.ObanWorkers.CommentNotifier

  @tag :as_user
  test "previewing a comment", %{conn: conn} do
    conn = post(conn, Routes.news_item_comment_path(conn, :preview), md: "## Ohai!")
    assert html_response(conn, 200) =~ "<h2>Ohai!</h2>"
  end

  test "does not create with no user", %{conn: conn} do
    item = insert(:published_news_item)
    count_before = count(NewsItemComment)

    conn =
      post(conn, Routes.news_item_comment_path(conn, :create),
        news_item_comment: %{content: "how dare thee!", item_id: item.id}
      )

    assert redirected_to(conn) == Routes.sign_in_path(conn, :new)
    assert count(NewsItemComment) == count_before
  end

  @tag :as_inserted_user
  test "does not create with no item id", %{conn: conn} do
    count_before = count(NewsItemComment)

    conn =
      post(conn, Routes.news_item_comment_path(conn, :create),
        news_item_comment: %{content: "yickie"}
      )

    assert redirected_to(conn) == Routes.root_path(conn, :index)
    assert count(NewsItemComment) == count_before
  end

  @tag :as_inserted_user
  test "creates comment and notifies if the commenter is approved", %{conn: conn} do
    item = insert(:published_news_item)

    with_mock(Notifier, notify: fn %NewsItemComment{approved: true} -> true end) do
      conn =
        post(conn, Routes.news_item_comment_path(conn, :create),
          news_item_comment: %{content: "how dare thee!", item_id: item.id}
        )

      [%NewsItemComment{id: id}] = Repo.all(NewsItemComment)

      assert redirected_to(conn) == Routes.root_path(conn, :index)
      assert count(NewsItemComment) == 1
      assert_enqueued([worker: CommentNotifier, args: %{"comment_id" => id}], 100)

      assert %{success: 1, failure: 0} =
               Oban.drain_queue(queue: :email, with_scheduled: true)

      assert called(Notifier.notify(:_))
    end
  end

  @tag :as_unapproved_user
  test "creates comment but does not notify if user is unapproved", %{conn: conn} do
    item = insert(:published_news_item)

    with_mock(Notifier, notify: fn %NewsItemComment{approved: false} -> true end) do
      conn =
        post(conn, Routes.news_item_comment_path(conn, :create),
          news_item_comment: %{content: "how dare thee!", item_id: item.id}
        )

      [%NewsItemComment{id: id}] = Repo.all(NewsItemComment)

      assert redirected_to(conn) == Routes.root_path(conn, :index)
      assert count(NewsItemComment) == 1
      assert_enqueued([worker: CommentNotifier, args: %{"comment_id" => id}], 100)

      assert %{success: 1, failure: 0} =
               Oban.drain_queue(queue: :email, with_scheduled: true)

      assert called(Notifier.notify(:_))
    end
  end

  @tag :as_inserted_user
  test "does not allow setting of author_id", %{conn: conn} do
    item = insert(:published_news_item)
    other = insert(:person)

    with_mock(Notifier, notify: fn _ -> true end) do
      conn =
        post(conn, Routes.news_item_comment_path(conn, :create),
          news_item_comment: %{content: "how dare thee!", item_id: item.id, author_id: other.id}
        )

      [%NewsItemComment{id: id}] = Repo.all(NewsItemComment)

      assert redirected_to(conn) == Routes.root_path(conn, :index)
      comment = Repo.one(NewsItemComment)

      assert_enqueued([worker: CommentNotifier, args: %{"comment_id" => id}], 100)

      assert %{success: 1, failure: 0} =
               Oban.drain_queue(queue: :email, with_scheduled: true)

      assert comment.author_id != other.id
      assert called(Notifier.notify(:_))
    end
  end

  @tag :as_inserted_user
  test "should be able to update comments within the time range", %{conn: conn} do
    item = insert(:published_news_item)

    post(conn, Routes.news_item_comment_path(conn, :create),
      news_item_comment: %{content: "how dare thee!", item_id: item.id}
    )

    [%NewsItemComment{id: id}] = Repo.all(NewsItemComment)

    assert NewsItemComment.get_by_id(id).content == "how dare thee!"

    assert patch(conn, Routes.news_item_comment_path(conn, :update, Changelog.Hashid.encode(id)),
             news_item_comment: %{content: "how dare thee!!!"}
           ).status == 302

    assert NewsItemComment.get_by_id(id).content == "how dare thee!!!"
  end

  @tag :as_inserted_user
  test "should not be able to update comments outside the time range", %{conn: conn} do
    item = insert(:published_news_item)

    post(conn, Routes.news_item_comment_path(conn, :create),
      news_item_comment: %{content: "how dare thee!", item_id: item.id}
    )

    [comment = %NewsItemComment{id: id}] = Repo.all(NewsItemComment)

    utc_now =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.truncate(:second)

    more_than_5_mins = 6 * 60

    updated_comment =
      Ecto.Changeset.change(comment, inserted_at: NaiveDateTime.add(utc_now, -more_than_5_mins))

    Repo.update!(updated_comment)

    assert NewsItemComment.get_by_id(id).content == "how dare thee!"

    assert patch(conn, Routes.news_item_comment_path(conn, :update, Changelog.Hashid.encode(id)),
             news_item_comment: %{content: "how dare thee!!!"}
           ).status == 404

    assert NewsItemComment.get_by_id(id).content == "how dare thee!"
  end

  @tag :as_inserted_user
  test "should not be able to update other people's comments", %{conn: conn} do
    other_user = Changelog.Factory.insert(:person, admin: false)

    item = insert(:published_news_item)

    post(conn, Routes.news_item_comment_path(conn, :create),
      news_item_comment: %{content: "how dare thee!", item_id: item.id}
    )

    [%NewsItemComment{id: id}] = Repo.all(NewsItemComment)

    assert NewsItemComment.get_by_id(id).content == "how dare thee!"

    assert %Plug.Conn{status: 404} =
             conn
             |> assign(:current_user, other_user)
             |> patch(Routes.news_item_comment_path(conn, :update, Changelog.Hashid.encode(id)),
               news_item_comment: %{content: "how dare thee!!!"}
             )
  end
end
