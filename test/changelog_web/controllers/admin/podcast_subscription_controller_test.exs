defmodule ChangelogWeb.Admin.PodcastSubscriptionControllerTest do
  use ChangelogWeb.ConnCase

  @tag :as_admin
  test "lists all subs on index", %{conn: conn} do
    podcast = insert(:podcast)
    p1 = insert(:person)
    p2 = insert(:person)
    insert(:subscription_on_podcast, podcast: podcast, person: p1)
    insert(:subscription_on_podcast, podcast: podcast, person: p2)

    conn = get(conn, Routes.admin_podcast_subscription_path(conn, :index, podcast.slug))

    assert html_response(conn, 200) =~ ~r/Subscriptions/
    assert String.contains?(conn.resp_body, p1.name)
    assert String.contains?(conn.resp_body, p2.name)
  end

  test "requires user auth on all actions", %{conn: conn} do
    podcast = insert(:podcast)
    insert(:subscription_on_podcast, podcast: podcast)

    Enum.each(
      [
        get(conn, Routes.admin_podcast_subscription_path(conn, :index, podcast.slug))
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end
    )
  end
end
