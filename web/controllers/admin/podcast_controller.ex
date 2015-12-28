defmodule Changelog.Admin.PodcastController do
  use Changelog.Web, :controller

  alias Changelog.Podcast

  plug :scrub_params, "podcast" when action in [:create, :update]

  def index(conn, _params) do
    podcasts = Repo.all from p in Podcast, order_by: p.id
    render conn, "index.html", podcasts: podcasts
  end

  def new(conn, _params) do
    changeset = Podcast.changeset(%Podcast{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"podcast" => podcast_params}) do
    changeset = Podcast.changeset(%Podcast{}, podcast_params)

    case Repo.insert(changeset) do
      {:ok, podcast} ->
        conn
        |> put_flash(:info, "#{podcast.name} created!")
        |> redirect(to: admin_podcast_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    podcast = Repo.get!(Podcast, id)
    changeset = Podcast.changeset(podcast)
    render conn, "edit.html", podcast: podcast, changeset: changeset
  end

  def update(conn, %{"id" => id, "podcast" => podcast_params}) do
    podcast = Repo.get!(Podcast, id)
    changeset = Podcast.changeset(podcast, podcast_params)

    case Repo.update(changeset) do
      {:ok, podcast} ->
        conn
        |> put_flash(:info, "#{podcast.name} udated!")
        |> redirect(to: admin_podcast_path(conn, :index))
      {:error, changeset} ->
        render conn, "edit.html", podcast: podcast, changeset: changeset
    end
  end
end
