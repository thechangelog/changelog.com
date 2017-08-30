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
      assert email.html_body =~ "shpedoinkel!"
    end

    test "with more options" do
      person = build(:person)
      email = Email.guest_thanks(person, %{"from" => "john@doe.com","message" => "shpedoinkel!"})

      assert email.to == person
      assert email.from == "john@doe.com"
      assert email.html_body =~ "shpedoinkel!"
    end
  end

  test "sign in" do
    person = build(:person, auth_token: "12345", auth_token_expires_at: Timex.now)
    email = Email.sign_in(person)

    assert email.to == person
    assert email.html_body =~ "sign in"
  end

  test "welcome" do
    person = build(:person, auth_token: "54321", auth_token_expires_at: Timex.now)
    email = Email.welcome(person)

    assert email.to == person
    assert email.subject =~ "Welcome"
    assert email.html_body =~ "Welcome"
  end
end
