defmodule ChangelogWeb.Email do
  use Bamboo.Phoenix, view: ChangelogWeb.EmailView

  def guest_thanks(person, opts) do
    from = opts["from"] || "editors@changelog.com"
    reply = opts["reply"] || "editors@changelog.com"
    subject = opts["subject"] || "Your episode is live!"
    message = opts["message"]

    personal_email()
    |> from(from)
    |> put_header("Reply-To", reply)
    |> put_header("X-CMail-GroupName", "Guest Thanks")
    |> to(person)
    |> subject(subject)
    |> assign(:person, person)
    |> assign(:message, message)
    |> render(:guest_thanks)
  end

  def guest_welcome(person) do
    logbot_email()
    |> put_header("X-CMail-GroupName", "Guest Welcome")
    |> to(person)
    |> subject("Thanks for guesting on a Changelog show!")
    |> assign(:person, person)
    |> render(:guest_welcome)
  end

  def sign_in(person) do
    logbot_email()
    |> put_header("X-CMail-GroupName", "Sign In")
    |> to(person)
    |> subject("Your Sign In Link")
    |> assign(:person, person)
    |> render(:sign_in)
  end

  def community_welcome(person) do
    logbot_email()
    |> put_header("X-CMail-GroupName", "Welcome")
    |> to(person)
    |> subject("Welcome! Confirm your address")
    |> assign(:person, person)
    |> render(:community_welcome)
  end

  def subscriber_welcome(person) do
    logbot_email()
    |> put_header("X-CMail-GroupName", "Welcome")
    |> to(person)
    |> subject("Welcome! Confirm your address")
    |> assign(:person, person)
    |> render(:subscriber_welcome)
  end

  def authored_news_published(person, item) do
    logbot_email()
    |> put_header("X-CMail-GroupName", "Authored News")
    |> to(person)
    |> subject("You're on Changelog News!")
    |> assign(:person, person)
    |> assign(:item, item)
    |> render(:authored_news_published)
  end

  def submitted_news_published(person, item) do
    logbot_email()
    |> put_header("X-CMail-GroupName", "Submitted News")
    |> to(person)
    |> subject("Your submission is on Changelog News!")
    |> assign(:person, person)
    |> assign(:item, item)
    |> render(:submitted_news_published)
  end

  defp logbot_email do
    new_email()
    |> from("logbot@changelog.com")
    |> put_header("Reply-To", "editors@changelog.com")
    |> put_html_layout({ChangelogWeb.LayoutView, "email_logbot.html"})
  end

  defp personal_email do
    new_email()
    |> put_html_layout({ChangelogWeb.LayoutView, "email_personal.html"})
  end
end

defimpl Bamboo.Formatter, for: Changelog.Person do
  def format_email_address(person, _opts) do
    {person.name, person.email}
  end
end
