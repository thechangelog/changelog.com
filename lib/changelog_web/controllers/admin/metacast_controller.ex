defmodule ChangelogWeb.Admin.MetacastController do
  use ChangelogWeb, :controller

  alias Changelog.{Cache, Metacast}

  plug :assign_metacast when action in [:edit, :update, :delete]
  plug Authorize, [Policies.AdminsOnly, :metacast]
  plug :scrub_params, "metacast" when action in [:create, :update]

  def index(conn, _params) do
    metacasts = Repo.all(Metacast)

    conn
    |> assign(:metacasts, metacasts)
    |> render(:index)
  end

  def new(conn, _params) do
    meta = %Metacast{}
    changeset = Metacast.insert_changeset(meta)
    render(conn, :new, changeset: changeset)
  end

  def create(conn, params = %{"metacast" => metacast_params}) do
    changeset = Metacast.insert_changeset(%Metacast{}, metacast_params)

    case Repo.insert(changeset) do
      {:ok, metacast} ->
        Repo.update(Metacast.file_changeset(metacast, metacast_params))
        Cache.delete(metacast)

        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, Routes.admin_metacast_path(conn, :edit, metacast))
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:new, changeset: changeset)
    end
  end

  def edit(conn = %{assigns: %{metacast: metacast}}, _params) do
    changeset = Metacast.update_changeset(metacast)
    render(conn, :edit, metacast: metacast, changeset: changeset)
  end

  def update(conn = %{assigns: %{metacast: metacast}}, params = %{"metacast" => metacast_params}) do
    changeset = Metacast.update_changeset(metacast, metacast_params)

    case Repo.update(changeset) do
      {:ok, metacast} ->
        Cache.delete(metacast)
        params = replace_next_edit_path(params, Routes.admin_metacast_path(conn, :edit, metacast))

        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, Routes.admin_metacast_path(conn, :index))
      {:error, changeset} ->
        render(conn, :edit, metacast: metacast, changeset: changeset)
    end
  end

  def delete(conn = %{assigns: %{metacast: metacast}}, _params) do
    Repo.delete!(metacast)

    conn
    |> put_flash(:result, "success")
    |> redirect(to: Routes.admin_metacast_path(conn, :index))
  end

  defp assign_metacast(conn = %{params: %{"id" => id}}, _) do
    metacast = Repo.get!(Metacast, id)
    assign(conn, :metacast, metacast)
  end
end