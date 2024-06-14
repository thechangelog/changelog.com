defmodule ChangelogWeb.Admin.MembershipController do
  use ChangelogWeb, :controller

  alias Changelog.{Membership, ObanWorkers}

  plug :assign_membership when action in [:edit, :update, :delete]
  plug Authorize, [Policies.Admin.Membership, :membership]
  plug :scrub_params, "membership" when action in [:create, :update]

  def index(conn, params) do
    filter = Map.get(params, "filter", "default")
    params = Map.put(params, :page_size, 1000)

    page =
      case filter do
        "default" -> Membership.active()
        "inactive" -> Membership.inactive()
        "unknown" -> Membership.unknown()
        _else -> Membership
      end
      |> Membership.newest_first(:started_at)
      |> Membership.preload_person()
      |> Repo.paginate(params)

    conn
    |> assign(:memberships, page.entries)
    |> assign(:filter, filter)
    |> assign(:page, page)
    |> render(:index)
  end

  def edit(conn = %{assigns: %{membership: membership}}, _params) do
    changeset = Membership.changeset(membership)
    render(conn, :edit, membership: membership, changeset: changeset)
  end

  def update(
        conn = %{assigns: %{membership: membership}},
        params = %{"membership" => membership_params}
      ) do
    changeset = Membership.changeset(membership, membership_params)

    case Repo.update(changeset) do
      {:ok, membership} ->
        params = replace_next_edit_path(params, ~p"/admin/memberships/#{membership}/edit")

        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, ~p"/admin/memberships")

      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:edit, membership: membership, changeset: changeset)
    end
  end

  def refresh(conn, params) do
    ObanWorkers.MembershipSyncer.queue()

    conn
    |> put_flash(:result, "success")
    |> redirect_next(params, ~p"/admin/memberships")
  end

  defp assign_membership(conn = %{params: %{"id" => id}}, _) do
    membership = Membership |> Repo.get(id) |> Membership.preload_person()

    assign(conn, :membership, membership)
  end
end
