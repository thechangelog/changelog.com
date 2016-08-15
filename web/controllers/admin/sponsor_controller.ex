defmodule Changelog.Admin.SponsorController do
  use Changelog.Web, :controller

  alias Changelog.Sponsor

  plug :scrub_params, "sponsor" when action in [:create, :update]

  def index(conn, params) do
    page = Sponsor
    |> order_by([p], desc: p.id)
    |> Repo.paginate(params)

    render conn, :index, sponsors: page.entries, page: page
  end

  def new(conn, _params) do
    changeset = Sponsor.changeset(%Sponsor{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, params = %{"sponsor" => sponsor_params}) do
    changeset = Sponsor.changeset(%Sponsor{}, sponsor_params)

    case Repo.insert(changeset) do
      {:ok, sponsor} ->
        conn
        |> put_flash(:result, "success")
        |> smart_redirect(sponsor, params)
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render("new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    sponsor = Repo.get!(Sponsor, id)
    changeset = Sponsor.changeset(sponsor)
    render(conn, "edit.html", sponsor: sponsor, changeset: changeset)
  end

  def update(conn, params = %{"id" => id, "sponsor" => sponsor_params}) do
    sponsor = Repo.get!(Sponsor, id)
    changeset = Sponsor.changeset(sponsor, sponsor_params)

    case Repo.update(changeset) do
      {:ok, sponsor} ->
        conn
        |> put_flash(:result, "success")
        |> smart_redirect(sponsor, params)
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render("edit.html", sponsor: sponsor, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    sponsor = Repo.get!(Sponsor, id)
    Repo.delete!(sponsor)

    conn
    |> put_flash(:result, "success")
    |> redirect(to: admin_sponsor_path(conn, :index))
  end

  defp smart_redirect(conn, _sponsor, %{"close" => _true}) do
    redirect(conn, to: admin_sponsor_path(conn, :index))
  end
  defp smart_redirect(conn, sponsor, _params) do
    redirect(conn, to: admin_sponsor_path(conn, :edit, sponsor))
  end
end
