defmodule ChangelogWeb.Admin.MailerPreviewController do
  use ChangelogWeb, :controller

  alias Changelog.{Episode, NewsItem, NewsItemComment, Person, Repo, Subscription}
  alias ChangelogWeb.Email

  def index(conn, _params) do
    previews =
      :functions
      |> __MODULE__.__info__()
      |> Enum.map(fn({name, _arity}) -> Atom.to_string(name) end)
      |> Enum.filter(fn(name) -> String.match?(name, ~r/_email/) end)
      |> Enum.map(fn(name) -> String.replace(name, "_email", "") end)

    render(conn, :index, previews: previews)
  end

  def show(conn, params = %{"id" => id}) do
    email = apply(__MODULE__, String.to_existing_atom("#{id}_email"), [])
    format = Map.get(params, "format", "html")

    conn
    |> put_layout(false)
    |> assign(:email, email)
    |> assign(:format, format)
    |> render(:show)
  end

  def authored_news_published_email do
    item =
      NewsItem.published()
      |> NewsItem.with_author()
      |> NewsItem.newest_first()
      |> NewsItem.limit(1)
      |> NewsItem.preload_all()
      |> Repo.one()

    Email.authored_news_published(item.author, item)
  end

  def comment_mention_email do
    comment =
      NewsItemComment.newest_first()
      |> NewsItemComment.limit(1)
      |> NewsItemComment.preload_all()
      |> Repo.one()

    # person doesn't matter because no actual mention detection here
    person = latest_person()

    Email.comment_mention(person, comment)
  end

  def comment_reply_email do
    comment =
      NewsItemComment.newest_first()
      |> NewsItemComment.replies()
      |> NewsItemComment.limit(1)
      |> NewsItemComment.preload_all()
      |> Repo.one()

    person =
      comment.parent
      |> NewsItemComment.preload_author()
      |> Map.get(:author)

    Email.comment_reply(person, comment)
  end

  def comment_subscription_email do
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

  def community_welcome_email do
    latest_person()
    |> Person.refresh_auth_token()
    |> Email.community_welcome()
  end

  def episode_published_email do
    Email.episode_published(known_subscription(), known_episode())
  end

  def episode_transcribed_email do
    Email.episode_transcribed(latest_person(), known_episode())
  end

  def guest_welcome_email do
    latest_person()
    |> Person.refresh_auth_token()
    |> Email.guest_welcome()
  end

  def guest_thanks_email do
    ep = known_episode()
    guest = List.first(ep.guests)
    Email.guest_thanks(guest, ep)
  end

  def subscriber_welcome_email do
    subscription = known_subscription()

    subscription.person()
    |> Person.refresh_auth_token()
    |> Email.subscriber_welcome(subscription.podcast)
  end

  defp latest_person do
    Person.newest_first()
    |> Person.limit(1)
    |> Repo.one()
  end

  defp known_episode do
    Episode
    |> Repo.get(654)
    |> Episode.preload_all()
  end

  defp known_subscription do
    Subscription
    |> Repo.get(1)
    |> Subscription.preload_all()
  end
end
