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
end
