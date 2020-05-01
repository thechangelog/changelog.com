defmodule ChangelogWeb.BenefitController do
  use ChangelogWeb, :controller

  alias Changelog.Benefit

  def index(conn, _params) do
    benefits = Repo.all(Benefit) |> Benefit.preload_all()
    render(conn, :index, benefits: benefits)
  end
end
