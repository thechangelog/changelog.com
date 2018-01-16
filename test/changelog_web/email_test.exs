defmodule ChangelogWeb.EmailTest do
  use ExUnit.Case
  use Bamboo.Test

  import Changelog.Factory

  alias ChangelogWeb.Email

  describe "guest thanks" do
    test "with mostly blank options" do
      person = build(:person)
      email = Email.guest_thanks(person, %{"message" => "shpedoinkel!"})

      assert email.to == person
      assert email.from == "editors@changelog.com"
      assert email.html_body =~ ~r/shpedoinkel!/i
    end

    test "with more options" do
      person = build(:person)
      email = Email.guest_thanks(person, %{"from" => "john@doe.com","message" => "shpedoinkel!"})

      assert email.to == person
      assert email.from == "john@doe.com"
      assert email.html_body =~ ~r/shpedoinkel!/i
    end
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
    assert email.html_body =~~r/welcome/i
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
    email = Email.subscriber_welcome(person)

    assert email.to == person
    assert email.subject =~ ~r/welcome/i
    assert email.html_body =~ ~r/subscribed/i
  end
end
