defmodule Changelog.Email do
  import Bamboo.Email

  def sign_in_email(person) do
    new_email
    |> from("robot@changelog.com")
    |> to(person)
    |> subject("Your Sign In Link")
    |> html_body("<p>Click here to sign in.</p>")
    |> text_body("Click here to sign in: ")
  end
end

defimpl Bamboo.Formatter, for: Changelog.Person do
  def format_email_address(person, _opts) do
    {person.name, person.email}
  end
end
