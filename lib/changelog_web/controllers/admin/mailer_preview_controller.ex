defmodule ChangelogWeb.Admin.MailerPreviewController do
  use ChangelogWeb, :controller

  alias Changelog.{Episode, NewsItem, Person, Repo, Subscription}
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

  def show(conn, %{"id" => id}) do
    email = apply(__MODULE__, String.to_existing_atom("#{id}_email"), [])

    conn
    |> put_layout(false)
    |> assign(:email, email)
    |> render(:show)
  end

  def community_welcome_email do
    person =
      Person.newest_first() |>
      Person.limit(1) |>
      Repo.one()

    Email.community_welcome(person)
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

  def episode_published_email do
    sub = Subscription |> Repo.get(1) |> Subscription.preload_all()
    ep =  Episode |> Repo.get(654) |> Episode.preload_podcast()
    Email.episode_published(sub, ep)
  end
end
