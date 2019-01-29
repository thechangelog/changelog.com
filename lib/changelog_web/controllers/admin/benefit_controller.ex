defmodule ChangelogWeb.Admin.BenefitController do
  use ChangelogWeb, :controller

  alias Changelog.Benefit

  plug :assign_benefit when action in [:edit, :update, :delete]
  plug Authorize, [Policies.AdminsOnly, :benefit]
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
    render(conn, :new, changeset: changeset)
  end

  def create(conn, params = %{"benefit" => benefit_params}) do
    changeset = Benefit.admin_changeset(%Benefit{}, benefit_params)

    case Repo.insert(changeset) do
      {:ok, benefit} ->
        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, admin_benefit_path(conn, :edit, benefit))
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:new, changeset: changeset)
    end
  end

  def edit(conn = %{assigns: %{benefit: benefit}}, _params) do
    benefit = Benefit.preload_all(benefit)
    changeset = Benefit.admin_changeset(benefit)
    render(conn, :edit, changeset: changeset)
  end

  def update(conn = %{assigns: %{benefit: benefit}}, params = %{"benefit" => benefit_params}) do
    benefit = Benefit.preload_all(benefit)
    changeset = Benefit.admin_changeset(benefit, benefit_params)

    case Repo.update(changeset) do
      {:ok, _benefit} ->
        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, admin_benefit_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:edit, benefit: benefit, changeset: changeset)
    end
  end

  def delete(conn = %{assigns: %{benefit: benefit}}, _params) do
    Repo.delete!(benefit)

    conn
    |> put_flash(:result, "success")
    |> redirect(to: admin_benefit_path(conn, :index))
  end

  defp assign_benefit(conn = %{params: %{"id" => id}}, _) do
    benefit = Repo.get!(Benefit, id)
    assign(conn, :benefit, benefit)
  end
end
