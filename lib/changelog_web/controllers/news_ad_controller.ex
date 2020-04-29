defmodule ChangelogWeb.NewsAdController do
  use ChangelogWeb, :controller

  alias Changelog.NewsAd
  alias ChangelogWeb.NewsAdView

  def show(conn, %{"id" => slug}) do
    hashid = slug |> String.split("-") |> List.last()
    ad = ad_from_hashid(hashid)

    if slug == hashid do
      redirect(conn, to: Routes.news_sponsored_path(conn, :show, NewsAd.slug(ad)))
    else
      render(conn, :show, ad: ad, sponsor: ad.sponsorship.sponsor)
    end
  end

  def impress(conn, %{"ads" => hashids}), do: impress(conn, %{"ids" => hashids})
  def impress(conn = %{assigns: %{current_user: user}}, %{"ids" => hashids}) do
    unless is_admin?(user) do
      hashids
      |> String.split(",")
      |> Enum.each(fn(hashid) ->
        hashid |> ad_from_hashid |> NewsAd.track_impression
      end)
    end

    send_resp(conn, 204, "")
  end

  def visit(conn = %{assigns: %{current_user: user}}, %{"id" => hashid}) do
    ad = ad_from_hashid(hashid)
    unless is_admin?(user), do: NewsAd.track_click(ad)

    conn
    |> put_layout(false)
    |> render(:visit, to: ad.url)
  end

  defp ad_from_hashid(hashid) do
    NewsAd
    |> Repo.get_by!(id: NewsAd.decode(hashid))
    |> NewsAd.preload_sponsorship()
  end
end
