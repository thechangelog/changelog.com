defmodule ChangelogWeb.EmailTest do
  use ExUnit.Case
  use Bamboo.Test

  import Changelog.Factory

  alias Changelog.Newsletters
  alias ChangelogWeb.Email

  test "guest thanks" do
    person = build(:person)
    episode = build(:published_episode)
    email = Email.guest_thanks(person, episode)

    assert email.to == person
    assert email.html_body =~ ~r/#{episode.title}/i
  end

  test "sign in" do
    person = build(:person, auth_token: "12345", auth_token_expires_at: Timex.now)
    email = Email.sign_in(person)

    assert email.to == person
    assert email.html_body =~ ~r/sign in/i
  end

  test "community welcome" do
    person = build(:person, auth_token: "54321", auth_token_expires_at: Timex.now)
    email = Email.community_welcome(person)

    assert email.to == person
    assert email.subject =~ ~r/welcome/i
    assert email.html_body =~ ~r/welcome/i
  end

  test "guest welcome" do
    person = build(:person, auth_token: "54321", auth_token_expires_at: Timex.now)
    email = Email.guest_welcome(person)

    assert email.to == person
    assert email.subject =~ ~r/guest/i
    assert email.html_body =~ ~r/guest/i
  end

  test "subscriber welcome" do
    person = build(:person, auth_token: "54321", auth_token_expires_at: Timex.now)
    email = Email.subscriber_welcome(person, Newsletters.weekly())

    assert email.to == person
    assert email.subject =~ ~r/welcome/i
    assert email.html_body =~ ~r/subscribed/i
    assert email.html_body =~ ~r/Changelog Weekly/
  end
end
