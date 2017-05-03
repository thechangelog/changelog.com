defmodule Changelog.Admin.BenefitController do
  use Changelog.Web, :controller

  alias Changelog.Benefit

  plug :scrub_params, "benefit" when action in [:create, :update]

  def index(conn, params) do
    page = Benefit
    |> order_by([p], desc: p.id)
    |> preload(:sponsor)
    |> Repo.paginate(params)

    render(conn, :index, benefits: page.entries, page: page)
  end

  def new(conn, _params) do
    changeset = Benefit.admin_changeset(%Benefit{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, params = %{"benefit" => benefit_params}) do
    changeset = Benefit.admin_changeset(%Benefit{}, benefit_params)

    case Repo.insert(changeset) do
      {:ok, benefit} ->
        conn
        |> put_flash(:result, "success")
        |> smart_redirect(benefit, params)
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render("new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    benefit = Repo.get!(Benefit, id) |> Benefit.preload_all
    changeset = Benefit.admin_changeset(benefit)
    render(conn, "edit.html", benefit: benefit, changeset: changeset)
  end

  def update(conn, params = %{"id" => id, "benefit" => benefit_params}) do
    benefit = Repo.get!(Benefit, id) |> Benefit.preload_all
    changeset = Benefit.admin_changeset(benefit, benefit_params)

    case Repo.update(changeset) do
      {:ok, benefit} ->
        conn
        |> put_flash(:result, "success")
        |> smart_redirect(benefit, params)
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render("edit.html", benefit: benefit, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    benefit = Repo.get!(Benefit, id)
    Repo.delete!(benefit)

    conn
    |> put_flash(:result, "success")
    |> redirect(to: admin_benefit_path(conn, :index))
  end

  defp smart_redirect(conn, _benefit, %{"close" => _true}) do
    redirect(conn, to: admin_benefit_path(conn, :index))
  end
  defp smart_redirect(conn, benefit, _params) do
    redirect(conn, to: admin_benefit_path(conn, :edit, benefit))
  end
end
