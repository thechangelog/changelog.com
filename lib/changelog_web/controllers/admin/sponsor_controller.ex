defmodule ChangelogWeb.Admin.SponsorController do
  use ChangelogWeb, :controller

  alias Changelog.{EpisodeSponsor, Fastly, NewsSponsorship, Sponsor}

  plug :assign_sponsor when action in [:show, :edit, :update, :delete]
  plug Authorize, [Policies.AdminsOnly, :sponsor]
  plug :scrub_params, "sponsor" when action in [:create, :update]

  def index(conn, _params) do
    sponsors =
      Sponsor
      |> Sponsor.newest_first(:updated_at)
      |> Sponsor.preload_reps()
      |> Repo.all()

    conn
    |> assign(:sponsors, sponsors)
    |> render(:index)
  end

  def show(conn = %{assigns: %{sponsor: sponsor}}, _params) do
    news_sponsorships =
      sponsor
      |> assoc(:news_sponsorships)
      |> NewsSponsorship.preload_all()
      |> Repo.all()

    episode_sponsorships =
      sponsor
      |> assoc(:episode_sponsors)
      |> EpisodeSponsor.newest_first()
      |> EpisodeSponsor.preload_episode()
      |> Repo.all()

    conn
    |> assign(:sponsor, sponsor)
    |> assign(:news_sponsorships, news_sponsorships)
    |> assign(:episode_sponsorships, episode_sponsorships)
    |> render(:show)
  end

  def new(conn, _params) do
    changeset = Sponsor.insert_changeset(%Sponsor{sponsor_reps: []})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, params = %{"sponsor" => sponsor_params}) do
    changeset = Sponsor.insert_changeset(%Sponsor{}, sponsor_params)

    case Repo.insert(changeset) do
      {:ok, sponsor} ->
        Repo.update(Sponsor.file_changeset(sponsor, sponsor_params))

        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, ~p"/admin/sponsors/#{sponsor}/edit")

      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:new, changeset: changeset)
    end
  end

  def edit(conn = %{assigns: %{sponsor: sponsor}}, _params) do
    sponsor = sponsor |> Sponsor.preload_reps()
    changeset = Sponsor.update_changeset(sponsor)
    render(conn, :edit, sponsor: sponsor, changeset: changeset)
  end

  def update(conn = %{assigns: %{sponsor: sponsor}}, params = %{"sponsor" => sponsor_params}) do
    sponsor =
      sponsor
      |> Sponsor.preload_reps()

    changeset = Sponsor.update_changeset(sponsor, sponsor_params)

    case Repo.update(changeset) do
      {:ok, sponsor} ->
        Fastly.purge(sponsor)

        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, ~p"/admin/sponsors")

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
    |> redirect(to: ~p"/admin/sponsors")
  end

  defp assign_sponsor(conn = %{params: %{"id" => id}}, _) do
    sponsor = Repo.get!(Sponsor, id)
    assign(conn, :sponsor, sponsor)
  end
end
