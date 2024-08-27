defmodule ChangelogWeb.HomeControllerTest do
  use ChangelogWeb.ConnCase

  import Mock

  alias Changelog.{NewsItem, Newsletters, Person, Subscription}

  @tag :as_user
  test "renders the home page", %{conn: conn} do
    conn = get(conn, ~p"/~")
    assert html_response(conn, 200)
  end

  @tag :as_user
  test "renders the account form", %{conn: conn} do
    conn = get(conn, ~p"/~/account")
    assert html_response(conn, 200) =~ "form"
  end

  @tag :as_user
  test "renders the profile form", %{conn: conn} do
    conn = get(conn, ~p"/~/profile")
    assert html_response(conn, 200) =~ "form"
  end

  @tag :as_inserted_user
  test "updates person and redirects to home page", %{conn: conn} do
    conn =
      put(conn, ~p"/~", from: "account", person: %{name: "New Name"})

    assert redirected_to(conn) == ~p"/~"
  end

  @tag :as_inserted_user
  test "does not update with invalid attributes", %{conn: conn} do
    conn = put(conn, ~p"/~", from: "profile", person: %{name: ""})
    assert html_response(conn, 200) =~ ~r/problem/
  end

  test "opting out of notifications", %{conn: conn} do
    person = insert(:person)
    {:ok, token} = Person.encoded_id(person)
    conn = post(conn, ~p"/~/nope/#{token}/setting/email_on_authored_news")

    assert conn.status == 200
    refute Repo.get(Person, person.id).settings.email_on_authored_news
  end

  test "opting out of a podcast subscription", %{conn: conn} do
    person = insert(:person)
    podcast = insert(:podcast)
    sub = insert(:subscription_on_podcast, person: person, podcast: podcast)
    {:ok, token} = Person.encoded_id(person)
    conn = post(conn, ~p"/~/nope/#{token}/podcast/#{podcast.slug}")

    assert redirected_to(conn) == ~p"/"
    refute Subscription.is_subscribed(Repo.get(Subscription, sub.id))
  end

  test "opting out of a podcast subscription with an invalid token", %{conn: conn} do
    podcast = insert(:podcast)
    conn = post(conn, ~p"/~/nope/S6LDYS205P5OZ51JSATUT4C/podcast/#{podcast.slug}")

    assert redirected_to(conn) == ~p"/"
  end

  test "opting out of a news subscription", %{conn: conn} do
    person = insert(:person)
    item = insert(:news_item)
    sub = insert(:subscription_on_podcast, person: person, item: item)
    {:ok, token} = Person.encoded_id(person)
    conn = post(conn, ~p"/~/nope/#{token}/news/#{item.id}")
    assert redirected_to(conn) == ~p"/news/#{NewsItem.slug(item)}"
    refute Subscription.is_subscribed(Repo.get(Subscription, sub.id))
  end

  test "muting a news discussion", %{conn: conn} do
    person = insert(:person)
    item = insert(:news_item)
    {:ok, token} = Person.encoded_id(person)
    conn = post(conn, ~p"/~/nope/#{token}/news/#{item.id}")
    assert redirected_to(conn) == ~p"/news/#{NewsItem.slug(item)}"
    assert Subscription.is_unsubscribed(person, item)
  end

  @tag :as_inserted_user
  test "subscribing to Changelog Nightly", %{conn: conn} do
    with_mock(Craisin.Subscriber, subscribe: fn _, _ -> true end) do
      nightly_id = Newsletters.nightly().id
      conn = post(conn, ~p"/~/subscribe?id=#{nightly_id}")
      assert called(Craisin.Subscriber.subscribe(nightly_id, :_))
      assert conn.status == 302
      assert count(Subscription.subscribed()) == 0
    end
  end

  @tag :as_inserted_user
  test "subscribing to a podcast", %{conn: conn} do
    podcast = insert(:podcast)
    conn = post(conn, ~p"/~/subscribe?slug=#{podcast.slug}")
    assert conn.status == 200
    assert count(Subscription.subscribed()) == 1
  end

  @tag :as_inserted_user
  test "unsubscribing from a podcast", %{conn: conn} do
    podcast = insert(:podcast)
    insert(:subscription_on_podcast, podcast: podcast, person: conn.assigns.current_user)
    assert count(Subscription.subscribed()) == 1
    conn = post(conn, ~p"/~/unsubscribe?slug=#{podcast.slug}")
    assert conn.status == 200
    assert count(Subscription.subscribed()) == 0
  end

  @tag :as_inserted_user
  test "unsubscribing from Changelog Nightly", %{conn: conn} do
    with_mock(Craisin.Subscriber, unsubscribe: fn _, _ -> true end) do
      nightly_id = Newsletters.nightly().id
      conn = post(conn, ~p"/~/unsubscribe?id=#{nightly_id}")
      assert called(Craisin.Subscriber.unsubscribe(nightly_id, :_))
      assert conn.status == 302
    end
  end

  @tag :as_inserted_user
  test "signed in and opting out of notifications", %{conn: conn} do
    person = conn.assigns.current_user
    {:ok, token} = Person.encoded_id(person)

    conn =
      post(conn, ~p"/~/nope/#{token}/setting/email_on_submitted_news")

    assert conn.status == 200
    refute Repo.get(Person, person.id).settings.email_on_submitted_news
  end

  test "requires user on all actions except email links", %{conn: conn} do
    Enum.each(
      [
        get(conn, ~p"/~"),
        get(conn, ~p"/~/profile"),
        get(conn, ~p"/~/account"),
        put(conn, ~p"/~", person: %{})
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end
    )
  end
end
