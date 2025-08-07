defmodule ChangelogWeb.Admin.PodcastSubscriptionControllerTest do
  use ChangelogWeb.ConnCase

  alias Changelog.{Person, Subscription}

  @tag :as_admin
  test "lists all subs on index", %{conn: conn} do
    podcast = insert(:podcast)
    p1 = insert(:person)
    p2 = insert(:person)
    insert(:subscription_on_podcast, podcast: podcast, person: p1)
    insert(:subscription_on_podcast, podcast: podcast, person: p2)

    conn = get(conn, ~p"/admin/podcasts/#{podcast.slug}/subscriptions")

    assert html_response(conn, 200) =~ ~r/Subscriptions/
    assert String.contains?(conn.resp_body, p1.name)
    assert String.contains?(conn.resp_body, p2.name)
  end

  @tag :as_admin
  test "imports new subs via CSV", %{conn: conn} do
    podcast = insert(:podcast)

    conn =
      post(conn, ~p"/admin/podcasts/#{podcast.slug}/subscriptions/import", %{
        "context" => "A test",
        "data" => %Plug.Upload{path: fixtures_path("/imports/subs.csv")}
      })

    assert count(Person) == 4
    assert count(Subscription) == 4
    assert_redirected_to(conn, ~p"/admin/podcasts/#{podcast.slug}/subscriptions")
  end

  test "requires user auth on all actions", %{conn: conn} do
    podcast = insert(:podcast)
    insert(:subscription_on_podcast, podcast: podcast)

    Enum.each(
      [
        get(conn, ~p"/admin/podcasts/#{podcast.slug}/subscriptions")
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end
    )
  end
end
