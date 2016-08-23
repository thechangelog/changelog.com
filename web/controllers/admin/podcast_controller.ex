defmodule Changelog.Admin.PodcastController do
  use Changelog.Web, :controller

  alias Changelog.Podcast

  plug :scrub_params, "podcast" when action in [:create, :update]

  def index(conn, _params) do
    podcasts = Repo.all from p in Podcast, order_by: p.id
    render conn, "index.html", podcasts: podcasts
  end

  def new(conn, _params) do
    changeset = Podcast.changeset(%Podcast{podcast_hosts: []})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, params = %{"podcast" => podcast_params}) do
    changeset = Podcast.changeset(%Podcast{}, podcast_params)

    case Repo.insert(changeset) do
      {:ok, podcast} ->
        conn
        |> put_flash(:result, "success")
        |> smart_redirect(podcast, params)
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render("new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => slug}) do
    podcast = Repo.get_by!(Podcast, slug: slug)
      |> Repo.preload([podcast_hosts: {Changelog.PodcastHost.by_position, :person}])
    changeset = Podcast.changeset(podcast)
    render conn, "edit.html", podcast: podcast, changeset: changeset
  end

  def update(conn, params = %{"id" => slug, "podcast" => podcast_params}) do
    podcast = Repo.get_by!(Podcast, slug: slug)
      |> Repo.preload(:podcast_hosts)
    changeset = Podcast.changeset(podcast, podcast_params)

    case Repo.update(changeset) do
      {:ok, podcast} ->
        conn
        |> put_flash(:result, "success")
        |> smart_redirect(podcast, params)
      {:error, changeset} ->
        render conn, "edit.html", podcast: podcast, changeset: changeset
    end
  end

  defp smart_redirect(conn, _podcast, %{"close" => _true}) do
    redirect(conn, to: admin_podcast_path(conn, :index))
  end
  defp smart_redirect(conn, podcast, _params) do
    redirect(conn, to: admin_podcast_path(conn, :edit, podcast.slug))
  end
end
