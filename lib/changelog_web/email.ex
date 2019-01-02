defmodule ChangelogWeb.Email do
  use Bamboo.Phoenix, view: ChangelogWeb.EmailView

  def guest_thanks(person, episode) do
    personal_email()
    |> put_header("X-CMail-GroupName", "Guest Thanks")
    |> to(person)
    |> subject("You're on #{episode.podcast.name}!")
    |> assign(:person, person)
    |> assign(:episode, episode)
    |> assign(:podcast, episode.podcast)
    |> render(:guest_thanks)
  end

  def guest_welcome(person) do
    styled_email()
    |> put_header("X-CMail-GroupName", "Guest Welcome")
    |> to(person)
    |> subject("Thanks for guesting on a Changelog show!")
    |> assign(:person, person)
    |> render(:guest_welcome)
  end

  def sign_in(person) do
    styled_email()
    |> put_header("X-CMail-GroupName", "Sign In")
    |> to(person)
    |> subject("Your Sign In Link")
    |> assign(:person, person)
    |> render(:sign_in)
  end

  def community_welcome(person) do
    styled_email()
    |> put_header("X-CMail-GroupName", "Welcome")
    |> to(person)
    |> subject("Welcome! Confirm your address")
    |> assign(:person, person)
    |> render(:community_welcome)
  end

  def subscriber_welcome(person, newsletter) do
    styled_email()
    |> put_header("X-CMail-GroupName", "Welcome")
    |> to(person)
    |> subject("Welcome! Confirm your address")
    |> assign(:person, person)
    |> assign(:newsletter, newsletter)
    |> render(:subscriber_welcome)
  end

  def authored_news_published(person, item) do
    styled_email()
    |> put_header("X-CMail-GroupName", "Authored News")
    |> to(person)
    |> subject("You're on Changelog News!")
    |> assign(:person, person)
    |> assign(:item, item)
    |> render(:authored_news_published)
  end

  def submitted_news_published(person, item) do
    styled_email()
    |> put_header("X-CMail-GroupName", "Submitted News")
    |> to(person)
    |> subject("Your submission is on Changelog News!")
    |> assign(:person, person)
    |> assign(:item, item)
    |> render(:submitted_news_published)
  end

  def comment_reply(person, reply) do
    styled_email()
    |> put_header("X-CMail-GroupName", "Comment Reply")
    |> to(person)
    |> subject("Someone replied to your comment on Changelog News!")
    |> assign(:person, person)
    |> assign(:reply, reply)
    |> render(:comment_reply)
  end

  defp email_from_logbot do
    new_email()
    |> from("logbot@changelog.com")
    |> put_header("Reply-To", "editors@changelog.com")
  end

  defp styled_email do
    email_from_logbot()
    |> put_html_layout({ChangelogWeb.LayoutView, "email_styled.html"})
  end

  defp personal_email do
    email_from_logbot()
    |> put_html_layout({ChangelogWeb.LayoutView, "email_personal.html"})
  end
end

defimpl Bamboo.Formatter, for: Changelog.Person do
  def format_email_address(person, _opts) do
    {person.name, person.email}
  end
end
