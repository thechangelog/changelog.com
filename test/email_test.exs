defmodule Changelog.EmailTest do
  use ExUnit.Case
  use Bamboo.Test

  import Changelog.Factory

  alias Changelog.Email

  test "sign in email" do
    person = build(:person, auth_token: "12345", auth_token_expires_at: Timex.now)
    email = Email.sign_in(person)

    assert email.to == person
    assert email.html_body =~ "sign in"
  end
end
