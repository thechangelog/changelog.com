defmodule ChangelogWeb.Admin.SponsorController do
  use ChangelogWeb, :controller

  alias Changelog.Sponsor

  plug :assign_sponsor when action in [:edit, :update, :delete]
  plug Authorize, [Policies.AdminsOnly, :sponsor]
  plug :scrub_params, "sponsor" when action in [:create, :update]

  def index(conn, params) do
    page = Sponsor
    |> order_by([p], desc: p.id)
    |> Repo.paginate(params)

    render(conn, :index, sponsors: page.entries, page: page)
  end

  def new(conn, _params) do
    changeset = Sponsor.insert_changeset(%Sponsor{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, params = %{"sponsor" => sponsor_params}) do
    changeset = Sponsor.insert_changeset(%Sponsor{}, sponsor_params)

    case Repo.insert(changeset) do
      {:ok, sponsor} ->
        Repo.update(Sponsor.file_changeset(sponsor, sponsor_params))

        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, admin_sponsor_path(conn, :edit, sponsor))
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:new, changeset: changeset)
    end
  end

  def edit(conn = %{assigns: %{sponsor: sponsor}}, _params) do
    changeset = Sponsor.update_changeset(sponsor)
    render(conn, :edit, sponsor: sponsor, changeset: changeset)
  end

  def update(conn = %{assigns: %{sponsor: sponsor}}, params = %{"sponsor" => sponsor_params}) do
    changeset = Sponsor.update_changeset(sponsor, sponsor_params)

    case Repo.update(changeset) do
      {:ok, _sponsor} ->
        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, admin_sponsor_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:edit, sponsor: sponsor, changeset: changeset)
    end
  end

  def delete(conn = %{assigns: %{sponsor: sponsor}}, _params) do
    Repo.delete!(sponsor)

    conn
    |> put_flash(:result, "success")
    |> redirect(to: admin_sponsor_path(conn, :index))
  end

  defp assign_sponsor(conn = %{params: %{"id" => id}}, _) do
    sponsor = Repo.get!(Sponsor, id)
    assign(conn, :sponsor, sponsor)
  end
end
