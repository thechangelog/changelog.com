defmodule Changelog.EmailTest do
  use ExUnit.Case
  use Bamboo.Test

  import Changelog.Factory

  alias Changelog.Email

  test "sign in email" do
    person = build(:person)
    email = Email.sign_in_email(person)

    assert email.to == person
    assert email.html_body =~ "Click here"
  end
end
