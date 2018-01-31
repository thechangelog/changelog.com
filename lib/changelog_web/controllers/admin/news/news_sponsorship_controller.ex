defmodule ChangelogWeb.Admin.NewsSponsorshipController do
  use ChangelogWeb, :controller

  alias Changelog.{NewsSponsorship}
  alias ChangelogWeb.TimeView

  plug :scrub_params, "news_sponsorship" when action in [:create, :update]

  def index(conn, params) do
    page =
      NewsSponsorship
      |> order_by([s], desc: s.id)
      |> NewsSponsorship.preload_all
      |> Repo.paginate(params)

    render(conn, :index, sponsorships: page.entries, page: page)
  end

  def show(conn, %{"id" => id}) do
    sponsorship = Repo.get!(NewsSponsorship, id) |> NewsSponsorship.preload_all()
    render(conn, :show, sponsorship: sponsorship)
  end

  def schedule(conn, params) do
    year = case Map.fetch(params, "year") do
      {:ok, value} -> String.to_integer(value)
      :error -> Timex.today.year
    end

    {:ok, start} = Date.new(year, 1, 1)
    start = TimeView.closest_monday_to(start)
    weeks = TimeView.weeks(start, 52)
    render(conn, :schedule, year: year, weeks: weeks)
  end

  def new(conn, params) do
    start_week = Map.get(params, "week", "")

    sponsorship = case Date.from_iso8601(start_week) do
      {:ok, date} -> %NewsSponsorship{weeks: [date]}
      {:error, _} -> %NewsSponsorship{}
    end

    changeset = NewsSponsorship.admin_changeset(sponsorship)
    render(conn, :new, changeset: changeset)
  end

  def create(conn, params = %{"news_sponsorship" => sponsorship_params}) do
    changeset = NewsSponsorship.admin_changeset(%NewsSponsorship{}, sponsorship_params)

    case Repo.insert(changeset) do
      {:ok, sponsorship} ->
        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, admin_news_sponsorship_path(conn, :edit, sponsorship))
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:new, changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    sponsorship = Repo.get!(NewsSponsorship, id) |> NewsSponsorship.preload_ads()
    changeset = NewsSponsorship.admin_changeset(sponsorship)
    render(conn, :edit, sponsorship: sponsorship, changeset: changeset)
  end

  def update(conn, params = %{"id" => id, "news_sponsorship" => sponsorship_params}) do
    sponsorship = Repo.get!(NewsSponsorship, id) |> NewsSponsorship.preload_ads()
    changeset = NewsSponsorship.admin_changeset(sponsorship, sponsorship_params)

    case Repo.update(changeset) do
      {:ok, _sponsorship} ->
        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, admin_news_sponsorship_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:edit, sponsorship: sponsorship, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    sponsorship = Repo.get!(NewsSponsorship, id)
    Repo.delete!(sponsorship)

    conn
    |> put_flash(:result, "success")
    |> redirect(to: admin_news_sponsorship_path(conn, :index))
  end
end
