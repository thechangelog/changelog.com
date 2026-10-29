defmodule ChangelogWeb.PreviewAccessTest do
  use ChangelogWeb.ConnCase

  alias Changelog.{Episode, NewsIssueItem, NewsItem, PodcastHost, Post}

  for actor <- [:anonymous, :user, :host, :editor, :admin] do
    for state <- [:draft, :scheduled] do
      test "#{actor} accessing a #{state} post preview", %{conn: conn} do
        user = actor(unquote(actor))
        factory = if unquote(state) == :draft, do: :post, else: :scheduled_post
        post = insert(factory, body: "PRIVATE_POST_BODY")
        response = conn |> session(user) |> get(~p"/posts/#{Post.hashid(post)}/preview")

        assert_preview(response, user, "PRIVATE_POST_BODY")
      end
    end

    test "#{actor} accessing a newsletter preview", %{conn: conn} do
      user = actor(unquote(actor))
      issue = insert(:news_issue, slug: "999001", note: "PRIVATE_ISSUE_NOTE")
      item = insert(:news_item, headline: "PRIVATE_ISSUE_ITEM")
      Repo.insert!(%NewsIssueItem{issue_id: issue.id, item_id: item.id, position: 1})
      ad = insert(:news_ad, headline: "PRIVATE_ISSUE_AD")
      insert(:news_issue_ad, issue: issue, ad: ad, position: 1)
      response = conn |> session(user) |> get(~p"/news/issues/#{issue.slug}/preview")

      for sentinel <- ["PRIVATE_ISSUE_NOTE", "PRIVATE_ISSUE_ITEM", "PRIVATE_ISSUE_AD"] do
        assert_preview(response, user, sentinel)
      end
    end

    for state <- [:draft, :queued, :submitted, :declined, :accepted, :future_published] do
      status = if state == :future_published, do: :published, else: state

      test "#{actor} accessing a #{state} news item preview", %{conn: conn} do
        user = actor(unquote(actor))
        insert(:podcast, slug: "news")

        item =
          insert(:news_item,
            status: unquote(status),
            published_at: hours_from_now(1),
            story: "PRIVATE_NEWS_STORY"
          )

        response = conn |> session(user) |> get(~p"/news/#{item.id}/preview")
        assert_preview(response, user, "PRIVATE_NEWS_STORY")

        unchanged = Repo.get!(NewsItem, item.id)
        assert unchanged.status == item.status
        assert unchanged.published_at == item.published_at
        assert unchanged.click_count == item.click_count
        assert unchanged.impression_count == item.impression_count
      end
    end

    for podcast_slug <- ["podcast", "news"], state <- [:draft, :scheduled, :undated] do
      test "#{actor} accessing #{state} #{podcast_slug} episode representations", %{conn: conn} do
        user = actor(unquote(actor))
        conn = session(conn, user)
        podcast = insert(:podcast, slug: unquote(podcast_slug))

        assign_host(podcast, user)

        attrs =
          case unquote(state) do
            :draft -> [published: false, published_at: hours_ago(1)]
            :scheduled -> [published: true, published_at: hours_from_now(1)]
            :undated -> [published: true, published_at: nil]
          end

        episode =
          insert(
            :episode,
            attrs ++
              [
                podcast: podcast,
                slug: "999007",
                title: "PRIVATE_EPISODE_TITLE",
                summary: "PRIVATE_EPISODE_SUMMARY",
                email_content: "## PRIVATE_NEWS_IMAGE",
                audio_file: %{file_name: "synthetic-private.mp3", updated_at: nil}
              ]
          )

        # /news/:slug/preview deliberately uses the NewsItemController's episode branch.
        preview = get(conn, "/#{podcast.slug}/#{episode.slug}/preview")
        assert_preview(preview, user, "PRIVATE_EPISODE_SUMMARY")

        play = get(conn, "/#{podcast.slug}/#{episode.slug}/play")
        assert_private(play)

        if admin?(user) do
          data = json_response(play, 200)
          assert data["title"] == "PRIVATE_EPISODE_TITLE"
          assert data["audio_url"] =~ "/#{podcast.slug}/#{episode.slug}/"
          assert String.ends_with?(data["audio_url"], ".mp3")
          assert length(data["chapters"]) == 2
        else
          assert_denied(play)
        end

        for shape <- ["rectangle", "square"] do
          image = get(conn, "/#{podcast.slug}/#{episode.slug}/img?shape=#{shape}")
          assert_preview(image, user, "PRIVATE_EPISODE_TITLE")
        end

        unchanged = Repo.get!(Episode, episode.id)
        assert unchanged.published == episode.published
        assert unchanged.published_at == episode.published_at
      end
    end

    test "#{actor} accessing previews with HEAD", %{conn: conn} do
      user = actor(unquote(actor))
      conn = session(conn, user)
      post = insert(:post)
      issue = insert(:news_issue, slug: "999008")
      item = insert(:news_item)
      podcast = insert(:podcast)
      episode = insert(:episode, podcast: podcast)

      for path <- [
            ~p"/posts/#{Post.hashid(post)}/preview",
            ~p"/news/issues/#{issue.slug}/preview",
            ~p"/news/#{item.id}/preview",
            ~p"/#{podcast.slug}/#{episode.slug}/preview",
            ~p"/#{podcast.slug}/#{episode.slug}/play",
            ~p"/#{podcast.slug}/#{episode.slug}/img"
          ] do
        response = head(conn, path)
        assert response.status == if(admin?(user), do: 200, else: 404)
        assert response.resp_body == ""
        assert_private(response)
      end
    end

    if actor != :admin do
      test "#{actor} is denied before preview resource lookup", %{conn: conn} do
        conn = conn |> session(actor(unquote(actor)))

        for path <- [
              "/posts/not-a-real-hash/preview",
              "/news/not-an-integer-or-episode/preview",
              "/news/issues/missing/preview",
              "/missing-podcast/missing-episode/preview"
            ] do
          assert_denied(get(conn, path))
        end
      end
    end
  end

  test "authorship, assigned editing and news logging do not grant preview access", %{conn: conn} do
    user = insert(:person, admin: false, editor: true, host: false)
    conn = session(conn, user)
    authored = insert(:post, author: user)
    edited = insert(:post, editor: user)
    item = insert(:news_item, logger: user)

    for path <- [
          ~p"/posts/#{Post.hashid(authored)}/preview",
          ~p"/posts/#{Post.hashid(edited)}/preview",
          ~p"/news/#{item.id}/preview"
        ] do
      assert_denied(get(conn, path))
    end
  end

  test "News episode preview renders once when its slug collides with a news item ID", %{
    conn: conn
  } do
    user = actor(:admin)
    item = insert(:news_item, story: "UNRELATED_NEWS_ITEM")
    podcast = insert(:podcast, slug: "news")
    insert(:episode, podcast: podcast, slug: to_string(item.id), summary: "NEWS_EPISODE_SUMMARY")

    response = conn |> session(user) |> get(~p"/news/#{item.id}/preview")
    assert_preview(response, user, "NEWS_EPISODE_SUMMARY")
    refute response.resp_body =~ "UNRELATED_NEWS_ITEM"
  end

  test "admin can preview a news item when no News podcast exists", %{conn: conn} do
    user = actor(:admin)
    item = insert(:news_item, story: "NEWS_ITEM_WITHOUT_PODCAST")
    response = conn |> session(user) |> get(~p"/news/#{item.id}/preview")
    assert_preview(response, user, "NEWS_ITEM_WITHOUT_PODCAST")
  end

  test "preview URLs require admin even for published content", %{conn: conn} do
    post = insert(:published_post)
    item = insert(:published_news_item)
    podcast = insert(:podcast)
    episode = insert(:published_episode, podcast: podcast)

    for path <- [
          ~p"/posts/#{Post.hashid(post)}/preview",
          ~p"/news/#{item.id}/preview",
          ~p"/#{podcast.slug}/#{episode.slug}/preview"
        ] do
      assert_denied(get(conn, path))
    end
  end

  for actor <- [:anonymous, :user, :admin] do
    test "#{actor} can access published content through public routes", %{conn: conn} do
      conn = session(conn, actor(unquote(actor)))
      post = insert(:published_post)
      issue = insert(:published_news_issue, slug: "999002")
      item = insert(:published_news_item)
      podcast = insert(:podcast)
      episode = insert(:published_episode, podcast: podcast)
      news = insert(:podcast, slug: "news")
      news_episode = insert(:published_episode, podcast: news, slug: "999003")

      for path <- [
            ~p"/posts/#{post.slug}",
            ~p"/news/issues/#{issue.slug}",
            ~p"/news/#{NewsItem.slug(item)}",
            ~p"/#{podcast.slug}/#{episode.slug}",
            ~p"/#{podcast.slug}/#{episode.slug}/embed",
            ~p"/#{podcast.slug}/#{episode.slug}/play",
            ~p"/#{podcast.slug}/#{episode.slug}/img",
            ~p"/#{news.slug}/#{news_episode.slug}/play",
            ~p"/#{news.slug}/#{news_episode.slug}/img"
          ] do
        response = get(conn, path)
        assert response.status == 200

        if unquote(actor) == :anonymous do
          assert get_resp_header(response, "surrogate-control") == [
                   Application.fetch_env!(:changelog, :cdn_cache_control_app)
                 ]
        else
          assert get_resp_header(response, "surrogate-control") == []
        end
      end
    end
  end

  defp actor(:anonymous), do: nil
  defp actor(:user), do: insert(:person, admin: false, editor: false, host: false)
  defp actor(:host), do: insert(:person, admin: false, editor: false, host: true)
  defp actor(:editor), do: insert(:person, admin: false, editor: true, host: false)
  defp actor(:admin), do: insert(:person, admin: true, editor: false, host: false)

  defp session(conn, nil), do: conn
  defp session(conn, user), do: Plug.Test.init_test_session(conn, %{"id" => user.id})

  defp admin?(user), do: match?(%{admin: true}, user)

  defp assign_host(podcast, %{host: true, id: id}) do
    Repo.insert!(%PodcastHost{podcast_id: podcast.id, person_id: id, retired: false})
  end

  defp assign_host(_podcast, _user), do: :ok

  defp assert_preview(response, user, sentinel) do
    if admin?(user) do
      assert html_response(response, 200) =~ sentinel
      assert response.assigns.current_user.id == user.id
      assert_private(response)
    else
      assert_denied(response)
      refute response.resp_body =~ sentinel
    end
  end

  defp assert_denied(response) do
    assert response.status == 404
    assert response.halted
    assert response.resp_body == "Not Found"
    assert get_resp_header(response, "location") == []
    assert_private(response)
  end

  defp assert_private(response) do
    assert get_resp_header(response, "cache-control") == ["private, no-store, must-revalidate"]
    assert get_resp_header(response, "surrogate-control") == ["no-store"]
    assert get_resp_header(response, "surrogate-key") == []
  end
end
