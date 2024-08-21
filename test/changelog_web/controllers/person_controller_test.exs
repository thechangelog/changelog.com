defmodule ChangelogWeb.PersonControllerTest do
  use ChangelogWeb.ConnCase
  use Changelog.EmailCase
  use Oban.Testing, repo: Changelog.Repo

  import Mock

  alias Changelog.{Newsletters, Person, Subscription}

  test "getting a person's page", %{conn: conn} do
    p = insert(:person)
    conn = get(conn, Routes.person_path(conn, :show, p.handle))
    assert html_response(conn, 200) =~ p.name
  end

  test "getting a person's page whose profile is private", %{conn: conn} do
    p = insert(:person, public_profile: false)

    assert_raise Ecto.NoResultsError, fn ->
      get(conn, Routes.person_path(conn, :show, p.handle))
    end
  end

  describe "joining" do
    test "getting the form", %{conn: conn} do
      conn = get(conn, Routes.person_path(conn, :join))

      assert conn.status == 200
      assert conn.resp_body =~ "form"
    end

    @tag :as_user
    test "getting form when signed in is not allowed", %{conn: conn} do
      conn = get(conn, Routes.person_path(conn, :join))
      assert html_response(conn, 302)
      assert conn.halted
    end

    test "submission with no data redirects", %{conn: conn} do
      conn = post(conn, Routes.person_path(conn, :join))
      assert redirected_to(conn) == Routes.person_path(conn, :join)
    end

    test "submission with missing data re-renders with errors", %{conn: conn} do
      count_before = count(Person)

      conn =
        with_mock(Changelog.Captcha, verify: fn _ -> true end) do
          post(conn, Routes.person_path(conn, :join), person: %{email: "nope"})
        end

      assert html_response(conn, 200) =~ ~r/wrong/i
      assert count(Person) == count_before
    end

    test "submission with failed captcha re-renders with errors", %{conn: conn} do
      count_before = count(Person)

      conn =
        with_mock(Changelog.Captcha, verify: fn _ -> false end) do
          post(conn, Routes.person_path(conn, :join), person: %{email: "nope"})
        end

      assert html_response(conn, 200) =~ ~r/robot/i
      assert count(Person) == count_before
    end

    test "submission with required data creates person, sends email, and redirects", %{conn: conn} do
      count_before = count(Person)

      conn =
        with_mocks([
          {Changelog.Captcha, [], [verify: fn _ -> true end]},
          {Craisin.Subscriber, [], [subscribe: fn _, _, _ -> nil end]}
        ]) do
          post(conn, Routes.person_path(conn, :join),
            person: %{email: "joe@blow.com", name: "Joe Blow", handle: "joeblow"}
          )
        end

      assert %{success: 1, failure: 0} = Oban.drain_queue(queue: :email)

      person = Repo.one(from p in Person, where: p.email == "joe@blow.com")
      refute person.public_profile
      assert_email_sent(ChangelogWeb.Email.community_welcome(person))
      assert redirected_to(conn) == Routes.root_path(conn, :index)
      assert count(Person) == count_before + 1
    end

    test "submission with Changelog News opt-in subscribes you to it as well", %{conn: conn} do
      news = insert(:podcast, slug: "news")
      count_before = count(Person)

      conn =
        with_mocks([
          {Changelog.Captcha, [], [verify: fn _ -> true end]},
          {Craisin.Subscriber, [], [subscribe: fn _, _, _ -> nil end]}
        ]) do
          post(conn, Routes.person_path(conn, :join),
            person: %{email: "joe@blow.com", name: "Joe Blow", handle: "joeblow"},
            news_subscribe: "on"
          )
        end

      assert %{success: 1, failure: 0} = Oban.drain_queue(queue: :email)

      person = Repo.one(from p in Person, where: p.email == "joe@blow.com")
      assert Subscription.is_subscribed(person, news)
      assert count(Subscription) == 1
      assert_email_sent(ChangelogWeb.Email.community_welcome(person))
      assert redirected_to(conn) == Routes.root_path(conn, :index)
      assert count(Person) == count_before + 1
    end

    test "submission with existing email re-renders with errors",
         %{conn: conn} do
      existing = insert(:person)
      count_before = count(Person)

      conn =
        with_mock(Changelog.Captcha, verify: fn _ -> true end) do
          post(conn, Routes.person_path(conn, :join),
            person: %{email: existing.email, name: "Joe Blow", handle: "joeblow"}
          )
        end

      assert %{success: 0, failure: 0} = Oban.drain_queue(queue: :email)

      assert html_response(conn, 200) =~ ~r/Member exists with that email address/i
      assert count(Person) == count_before
      assert existing.name != "Joe Blow"
    end
  end

  describe "subscribing in general" do
    test "getting the form", %{conn: conn} do
      conn = get(conn, Routes.person_path(conn, :subscribe))
      assert conn.status == 200
      assert conn.resp_body =~ "form"
    end

    test "submission with no data redirects", %{conn: conn} do
      conn = post(conn, Routes.person_path(conn, :subscribe))
      assert redirected_to(conn) == Routes.person_path(conn, :subscribe)
    end

    test "submission with failed captcha redirects", %{conn: conn} do
      with_mocks([
        {Changelog.Captcha, [], [verify: fn _ -> false end]}
      ]) do
        conn = post(conn, Routes.person_path(conn, :subscribe), email: "joe@blow.com")
        assert called(Changelog.Captcha.verify(:_))
        assert redirected_to(conn) == Routes.person_path(conn, :subscribe, "news")
      end
    end
  end

  describe "subscribing to newsletters" do
    test "getting the form", %{conn: conn} do
      conn = get(conn, Routes.person_path(conn, :subscribe, to: "nightly"))
      assert conn.status == 200
      assert conn.resp_body =~ "form"
    end

    test "with required data creates person, subscribes, sends email, redirects", %{conn: conn} do
      with_mocks([
        {Changelog.Captcha, [], [verify: fn _ -> true end]},
        {Craisin.Subscriber, [], [subscribe: fn _, _ -> nil end]}
      ]) do
        count_before = count(Person)

        conn = post(conn, Routes.person_path(conn, :subscribe), email: "joe@blow.com", name: "", to: "nightly")

        person = Repo.one(from p in Person, where: p.email == "joe@blow.com")
        refute person.public_profile
        assert called(Craisin.Subscriber.subscribe(Newsletters.nightly().id, :_))

        assert %{success: 1, failure: 0} = Oban.drain_queue(queue: :email)

        assert_email_sent(
          ChangelogWeb.Email.subscriber_welcome(person, Newsletters.nightly())
        )

        assert redirected_to(conn) == Routes.root_path(conn, :index)
        assert count(Person) == count_before + 1
      end
    end

    test "with existing email subscribes, sends email, redirects, but doesn't create person", %{
      conn: conn
    } do
      with_mocks([
        {Changelog.Captcha, [], [verify: fn _ -> true end]},
        {Craisin.Subscriber, [], [subscribe: fn _, _ -> nil end]}
      ]) do
        existing = insert(:person)
        count_before = count(Person)

        conn =
          post(conn, Routes.person_path(conn, :subscribe), email: existing.email, to: "nightly")

        existing = Repo.one(from p in Person, where: p.email == ^existing.email)

        assert called(Craisin.Subscriber.subscribe(Newsletters.nightly().id, :_))

        assert %{success: 1, failure: 0} = Oban.drain_queue(queue: :email)

        assert_email_sent(
          ChangelogWeb.Email.subscriber_welcome(existing, Newsletters.nightly())
        )

        assert redirected_to(conn) == Routes.root_path(conn, :index)
        assert count(Person) == count_before
      end
    end
  end

  describe "subscribing to podcasts" do
    test "getting the form", %{conn: conn} do
      podcast = insert(:podcast)
      conn = get(conn, Routes.person_path(conn, :subscribe, to: podcast.slug))
      assert conn.status == 200
      assert conn.resp_body =~ "form"
    end

    test "with required data creates person, subscribes, sends email, redirects", %{conn: conn} do
      with_mocks([
        {Changelog.Captcha, [], [verify: fn _ -> true end]}
      ]) do
        podcast = insert(:podcast)
        count_before = count(Person)

        conn =
          post(conn, Routes.person_path(conn, :subscribe), email: "joe@blow.com", to: podcast.slug)

        person = Repo.one(from p in Person, where: p.email == "joe@blow.com")

        assert %{success: 1, failure: 0} = Oban.drain_queue(queue: :email)

        assert_email_sent(ChangelogWeb.Email.subscriber_welcome(person, podcast))
        assert redirected_to(conn) == Routes.root_path(conn, :index)
        assert count(Person) == count_before + 1
        assert count(Subscription) == 1
      end
    end

    test "submission with Changelog News opt-in subscribes you to it as well", %{conn: conn} do
      news = insert(:podcast, slug: "news")

      with_mocks([
        {Changelog.Captcha, [], [verify: fn _ -> true end]}
      ]) do
        podcast = insert(:podcast)
        count_before = count(Person)

        conn =
          post(conn, Routes.person_path(conn, :subscribe), email: "joe@blow.com", news_subscribe: "on", to: podcast.slug)

        person = Repo.one(from p in Person, where: p.email == "joe@blow.com")

        assert %{success: 1, failure: 0} = Oban.drain_queue(queue: :email)

        assert_email_sent(ChangelogWeb.Email.subscriber_welcome(person, podcast))
        assert Subscription.is_subscribed(person, news)
        assert redirected_to(conn) == Routes.root_path(conn, :index)
        assert count(Person) == count_before + 1
        assert count(Subscription) == 2
      end
    end

    test "with existing email subscribes, sends email, redirects, but doesn't create person", %{
      conn: conn
    } do
      podcast = insert(:podcast)
      existing = insert(:person)
      count_before = count(Person)

      conn =
        with_mocks([
          {Changelog.Captcha, [], [verify: fn _ -> true end]}
        ]) do
          post(conn, Routes.person_path(conn, :subscribe), email: existing.email, to: podcast.slug)
        end

      existing = Repo.one(from p in Person, where: p.email == ^existing.email)

      assert %{success: 1, failure: 0} = Oban.drain_queue(queue: :email)

      assert_email_sent(ChangelogWeb.Email.subscriber_welcome(existing, podcast))
      assert redirected_to(conn) == Routes.root_path(conn, :index)
      assert count(Person) == count_before
      assert count(Subscription) == 1
    end
  end
end
