defmodule ChangelogWeb.NewsAdController do
  use ChangelogWeb, :controller

  alias Changelog.{Hashid, NewsAd}
  alias ChangelogWeb.NewsAdView

  plug :assign_ad

  def action(conn, _) do
    arg_list = [conn, conn.params, conn.assigns.ad]
    apply(__MODULE__, action_name(conn), arg_list)
  end

  def show(conn, _params, ad) do
    render(conn, :show, ad: ad, sponsor: ad.sponsorship.sponsor)
  end

  def impress(conn, _params, ad) do
    NewsAd.track_impression(ad)
    send_resp(conn, 200, "")
  end

  def visit(conn, _params, ad) do
    NewsAd.track_click(ad)
    redirect(conn, external: ad.url)
  end

  defp assign_ad(conn, _) do
    slug = conn.params["id"]
    hashid = slug |> String.split("-") |> List.last

    ad = NewsAd
    |> Repo.get_by!(id: Hashid.decode(hashid))
    |> NewsAd.preload_sponsorship

    if slug == hashid do
      conn
      |> redirect(to: news_ad_path(conn, :show, NewsAdView.slug(ad)))
      |> halt()
    else
      assign(conn, :ad, ad)
    end
  end
end
