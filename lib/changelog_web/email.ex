defmodule ChangelogWeb.Email do
  use Bamboo.Phoenix, view: ChangelogWeb.EmailView

  alias Changelog.{EpisodeGuest, EpisodeRequest, NewsItem}
  alias ChangelogWeb.EpisodeView

  # Comment related emails
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

  def unapproved_commentator(admin_recipient, comment) do
    item = NewsItem.load_object(comment.news_item)

    styled_email()
    |> put_header("X-CMail-GroupName", "Unapproved Commentator")
    |> to(admin_recipient)
    |> subject("New unapproved comment on `#{comment.news_item.headline}`")
    |> assign(:comment, comment)
    |> assign(:item, item)
    |> render(:unapproved_commentator)
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

  # Welcome emails
  def community_welcome(person) do
    styled_email()
    |> put_header("X-CMail-GroupName", "Community Welcome")
    |> to(person)
    |> subject("Welcome! Confirm your address")
    |> assign(:person, person)
    |> render(:community_welcome)
  end

  def guest_welcome(person) do
    styled_email()
    |> put_header("X-CMail-GroupName", "Guest Welcome")
    |> to(person)
    |> subject("Thanks for guesting on a Changelog show!")
    |> assign(:person, person)
    |> render(:guest_welcome)
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

  def sign_in(person) do
    styled_email()
    |> put_header("X-CMail-GroupName", "Sign In")
    |> to(person)
    |> subject("Your magic link")
    |> assign(:person, person)
    |> render(:sign_in)
  end

  # Podcast related emails
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

  def episode_request_declined(request) do
    styled_email()
    |> put_header("X-CMail-GroupName", "Declined Episode Request")
    |> to(request.submitter)
    |> subject("Your episode request of #{request.podcast.name}")
    |> assign(:person, request.submitter)
    |> assign(:request, request)
    |> render(:episode_request_declined)
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

  def guest_thanks(episode_guest) do
    episode_guest = EpisodeGuest.preload_all(episode_guest)

    personal_email()
    |> put_header("X-CMail-GroupName", "Guest Thanks")
    |> to(episode_guest.person)
    |> subject("You're on #{episode_guest.episode.podcast.name}!")
    |> assign(:person, episode_guest.person)
    |> assign(:episode, episode_guest.episode)
    |> assign(:discount_code, episode_guest.discount_code)
    |> assign(:podcast, episode_guest.episode.podcast)
    |> render(:guest_thanks)
  end

  # News related emails
  def authored_news_published(item) do
    styled_email()
    |> put_header("X-CMail-GroupName", "Authored News")
    |> to(item.author)
    |> subject("You're on Changelog News!")
    |> assign(:person, item.author)
    |> assign(:item, item)
    |> render(:authored_news_published)
  end

  def submitted_news_published(item) do
    styled_email()
    |> put_header("X-CMail-GroupName", "Submitted News")
    |> to(item.submitter)
    |> subject("Your submission is on Changelog News!")
    |> assign(:person, item.submitter)
    |> assign(:item, item)
    |> render(:submitted_news_published)
  end

  def submitted_news_declined(item) do
    styled_email()
    |> put_header("X-CMail-GroupName", "Declined News")
    |> to(item.submitter)
    |> subject("Your submission to Changelog News")
    |> assign(:person, item.submitter)
    |> assign(:item, item)
    |> render(:submitted_news_declined)
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
