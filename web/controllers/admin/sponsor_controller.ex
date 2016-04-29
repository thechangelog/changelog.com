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

  def create(conn, %{"sponsor" => sponsor_params}) do
    changeset = Sponsor.changeset(%Sponsor{}, sponsor_params)

    case Repo.insert(changeset) do
      {:ok, sponsor} ->
        conn
        |> put_flash(:info, "#{sponsor.name} created!")
        |> redirect(to: admin_sponsor_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
