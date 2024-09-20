defmodule ChangelogWeb.Admin.MailerPreviewController do
  use ChangelogWeb, :controller

  alias Changelog.{
    Episode,
    EpisodeGuest,
    EpisodeRequest,
    Feed,
    Mailer,
    NewsItem,
    NewsItemComment,
    Person,
    Repo,
    Subscription
  }

  alias ChangelogWeb.Email

  plug Authorize, Policies.AdminsOnly

  def index(conn, _params) do
    previews =
      :functions
      |> __MODULE__.__info__()
      |> Enum.map(fn {name, _arity} -> Atom.to_string(name) end)
      |> Enum.filter(fn name -> String.match?(name, ~r/_email/) end)
      |> Enum.map(fn name -> String.replace(name, "_email", "") end)

    render(conn, :index, previews: previews)
  end

  def show(conn = %{assigns: %{current_user: me}}, params = %{"id" => id}) do
    email = apply(__MODULE__, String.to_existing_atom("#{id}_email"), [me])

    conn
    |> put_layout(false)
    |> assign(:email, email)
    |> assign(:mailer, id)
    |> assign(:format, Map.get(params, "format", "html"))
    |> render(:show)
  end

  def send(conn = %{assigns: %{current_user: me}}, %{"id" => id}) do
    __MODULE__
    |> apply(String.to_existing_atom("#{id}_email"), [me])
    |> Mailer.deliver()

    conn
    |> put_flash(:result, :success)
    |> redirect(to: ~p"/admin/mailers")
  end

  # Welcome emails
  def community_welcome_email(person) do
    person |> Person.refresh_auth_token() |> Email.community_welcome()
  end

  def guest_welcome_email(person) do
    person |> Person.refresh_auth_token() |> Email.guest_welcome()
  end

  def subscriber_welcome_email(person) do
    subscription = known_subscription(person)

    subscription.person
    |> Person.refresh_auth_token()
    |> Email.subscriber_welcome(subscription.podcast)
  end

  # Comment related emails
  def comment_approval_email(person) do
    comment =
      NewsItemComment.newest_first()
      |> NewsItemComment.limit(1)
      |> NewsItemComment.preload_all()
      |> Repo.one()

    Email.comment_approval(person, comment)
  end

  def comment_mention_email(person) do
    comment =
      NewsItemComment.newest_first()
      |> NewsItemComment.limit(1)
      |> NewsItemComment.preload_all()
      |> Repo.one()

    Email.comment_mention(person, comment)
  end

  def comment_reply_email(person) do
    comment =
      NewsItemComment.newest_first()
      |> NewsItemComment.replies()
      |> NewsItemComment.limit(1)
      |> NewsItemComment.preload_all()
      |> Repo.one()

    # person =
    #   comment.parent
    #   |> NewsItemComment.preload_author()
    #   |> Map.get(:author)

    Email.comment_reply(person, comment)
  end

  def comment_subscription_email(_person) do
    comment =
      NewsItemComment.newest_first()
      |> NewsItemComment.limit(1)
      |> NewsItemComment.preload_all()
      |> Repo.one()

    subscription =
      Subscription.on_item(comment.news_item)
      |> Subscription.preload_all()
      |> Subscription.limit(1)
      |> Repo.one()

    Email.comment_subscription(subscription, comment)
  end

  def feed_links_email(person) do
    feed =
      person
      |> assoc(:feeds)
      |> Feed.limit(1)
      |> Feed.preload_owner()
      |> Repo.one()

    Email.feed_links(feed)
  end

  # Podcast related emails
  def episode_published_email(person) do
    Email.episode_published(known_subscription(person), known_episode())
  end

  def news_published_email(person) do
    episode =
      Episode.with_podcast_slug("news")
      |> Episode.limit(1)
      |> Episode.newest_first()
      |> Episode.preload_all()
      |> Repo.one()

    Email.episode_published(known_subscription(person), episode)
  end

  def episode_request_published_email(_person) do
    request =
      EpisodeRequest
      |> EpisodeRequest.limit(1)
      |> EpisodeRequest.with_episode()
      |> EpisodeRequest.preload_all()
      |> Repo.one()

    Email.episode_request_published(request)
  end

  def episode_request_declined_email(_person) do
    request =
      EpisodeRequest
      |> EpisodeRequest.declined()
      |> EpisodeRequest.with_message()
      |> EpisodeRequest.newest_first()
      |> EpisodeRequest.limit(1)
      |> EpisodeRequest.preload_all()
      |> Repo.one()

    Email.episode_request_declined(request)
  end

  def episode_transcribed_email(person) do
    Email.episode_transcribed(person, known_episode())
  end

  def guest_thanks_email(person) do
    episode_guest =
      person
      |> assoc(:episode_guests)
      |> EpisodeGuest.newest_first()
      |> EpisodeGuest.limit(1)
      |> Repo.one()

    Email.guest_thanks(episode_guest)
  end

  # News related emails
  def authored_news_published_email(person) do
    item =
      person
      |> assoc(:authored_news_items)
      |> NewsItem.published()
      |> NewsItem.newest_first()
      |> NewsItem.limit(1)
      |> NewsItem.preload_all()
      |> Repo.one()

    Email.authored_news_published(item)
  end

  def submitted_news_accepted_email(_person) do
    item =
      NewsItem
      |> NewsItem.accepted()
      |> NewsItem.with_object()
      |> NewsItem.newest_first()
      |> NewsItem.limit(1)
      |> NewsItem.preload_all()
      |> Repo.one()

    Email.submitted_news_accepted(item)
  end

  def submitted_news_declined_email(_person) do
    item =
      NewsItem
      |> NewsItem.declined()
      |> NewsItem.limit(1)
      |> NewsItem.preload_all()
      |> Repo.one()

    Email.submitted_news_declined(item)
  end

  defp known_episode do
    Episode
    |> Repo.get(654)
    |> Episode.preload_all()
  end

  defp known_subscription(person) do
    Subscription.for_person(person)
    |> Subscription.preload_all()
    |> Subscription.limit(1)
    |> Repo.one()
  end
end
