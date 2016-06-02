defmodule Changelog.Email do
  use Bamboo.Phoenix, view: Changelog.EmailView

  def sign_in_email(person) do
    base_email
    |> to(person)
    |> subject("Your Sign In Link")
    |> assign(:person, person)
    |> render(:sign_in)
  end

  defp base_email do
    new_email
    |> from("Rob Ot<robot@changelog.com>")
    |> put_header("Reply-To", "editors@changelog.com")
    |> put_html_layout({Changelog.LayoutView, "email.html"})
  end
end

defimpl Bamboo.Formatter, for: Changelog.Person do
  def format_email_address(person, _opts) do
    {person.name, person.email}
  end
end
