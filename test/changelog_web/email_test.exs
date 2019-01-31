defmodule ChangelogWeb.EmailTest do
  use ExUnit.Case
  use Bamboo.Test

  import Changelog.Factory

  alias Changelog.Newsletters
  alias ChangelogWeb.Email

  setup do
    person = build(:person, auth_token: "54321", auth_token_expires_at: Timex.now)
    {:ok, person: person}
  end

  test "community welcome", %{person: person} do
    email = Email.community_welcome(person)

    assert email.to == person
    assert email.subject =~ ~r/welcome/i
    assert email.html_body =~ ~r/welcome/i
  end

  test "episode published", %{person: person} do
    podcast = build(:podcast)
    sub = build(:subscription_on_podcast, id: 1, person: person, podcast: podcast)
    episode = build(:published_episode, podcast: podcast)
    email = Email.episode_published(sub, episode)

    assert email.to == person
    assert email.subject =~ ~r/#{podcast.name}/i
  end

  test "guest welcome", %{person: person} do
    email = Email.guest_welcome(person)

    assert email.to == person
    assert email.subject =~ ~r/guest/i
    assert email.html_body =~ ~r/guest/i
  end

  test "guest thanks", %{person: person} do
    episode = build(:published_episode)
    email = Email.guest_thanks(person, episode)

    assert email.to == person
    assert email.html_body =~ ~r/#{episode.title}/i
  end

  test "sign in", %{person: person} do
    email = Email.sign_in(person)

    assert email.to == person
    assert email.html_body =~ ~r/sign in/i
  end

  test "subscriber welcome to newsletter", %{person: person} do
    email = Email.subscriber_welcome(person, Newsletters.weekly())

    assert email.to == person
    assert email.subject =~ ~r/welcome/i
    assert email.html_body =~ ~r/subscribed/i
    assert email.html_body =~ ~r/Changelog Weekly/
  end

  test "subscriber welcome to podcast", %{person: person} do
    podcast = build(:podcast)
    email = Email.subscriber_welcome(person, podcast)

    assert email.to == person
    assert email.subject =~ ~r/welcome/i
    assert email.html_body =~ ~r/subscribed/i
    assert email.html_body =~ ~r/#{podcast.name}/
  end
end
