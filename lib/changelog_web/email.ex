defmodule ChangelogWeb.Email do
  use Bamboo.Phoenix, view: ChangelogWeb.EmailView

  alias Changelog.{EpisodeRequest, NewsItem}
  alias ChangelogWeb.EpisodeView

  def authored_news_published(person, item) do
    styled_email()
    |> put_header("X-CMail-GroupName", "Authored News")
    |> to(person)
    |> subject("You're on Changelog News!")
    |> assign(:person, person)
    |> assign(:item, item)
    |> render(:authored_news_published)
  end

  def comment_mention(person, comment) do
    item = NewsItem.load_object(comment.news_item)

    styled_email()
    |> put_header("X-CMail-GroupName", "Comment Mention")
    |> to(person)
    |> subject("Someone mentioned you on Changelog News")
    |> assign(:person, person)
    |> assign(:comment, comment)
    |> assign(:item, item)
    |> render(:comment_mention)
  end

  def comment_reply(person, reply) do
    item = NewsItem.load_object(reply.news_item)

    styled_email()
    |> put_header("X-CMail-GroupName", "Comment Reply")
    |> to(person)
    |> subject("Someone replied to you on Changelog News")
    |> assign(:person, person)
    |> assign(:reply, reply)
    |> assign(:item, item)
    |> render(:comment_reply)
  end

  def comment_subscription(subscription, comment) do
    item = NewsItem.load_object(comment.news_item)

    styled_email()
    |> put_header("X-CMail-GroupName", "Comment Subscription")
    |> to(subscription.person)
    |> subject("New comment on '#{comment.news_item.headline}'")
    |> assign(:subscription, subscription)
    |> assign(:person, subscription.person)
    |> assign(:comment, comment)
    |> assign(:item, item)
    |> render(:comment_subscription)
  end

  def community_welcome(person) do
    styled_email()
    |> put_header("X-CMail-GroupName", "Community Welcome")
    |> to(person)
    |> subject("Welcome! Confirm your address")
    |> assign(:person, person)
    |> render(:community_welcome)
  end

  def episode_published(subscription, episode) do
    styled_email()
    |> put_header("X-CMail-GroupName", "#{episode.podcast.name} #{episode.slug}")
    |> to(subscription.person)
    |> subject(EpisodeView.title_with_guest_focused_subtitle_and_podcast_aside(episode))
    |> assign(:subscription, subscription)
    |> assign(:person, subscription.person)
    |> assign(:episode, episode)
    |> render(:episode_published)
  end

  def episode_request_published(request) do
    request = EpisodeRequest.preload_all(request)

    styled_email()
    |> put_header("X-CMail-GroupName", "Episode Request")
    |> to(request.submitter)
    |> subject("Your requested episode is a thing!")
    |> assign(:person, request.submitter)
    |> assign(:episode, request.episode)
    |> assign(:podcast, request.podcast)
    |> render(:episode_request_published)
  end

  def episode_transcribed(person, episode) do
    styled_email()
    |> put_header("X-CMail-GroupName", "#{episode.podcast.name} #{episode.slug} Transcribed")
    |> to(person)
    |> subject("Transcript published for #{episode.podcast.name} #{episode.slug}")
    |> assign(:person, person)
    |> assign(:episode, episode)
    |> render(:episode_transcribed)
  end

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
    |> subject("Your magic link")
    |> assign(:person, person)
    |> render(:sign_in)
  end

  def subscriber_welcome(person, subscribed_to) do
    styled_email()
    |> put_header("X-CMail-GroupName", "Subscriber Welcome")
    |> to(person)
    |> subject("Welcome! Confirm your address")
    |> assign(:person, person)
    |> assign(:subscribed_to, subscribed_to)
    |> render(:subscriber_welcome)
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

  defp email_from_logbot do
    new_email()
    |> from({"Logbot", "logbot@changelog.com"})
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
