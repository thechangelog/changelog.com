defmodule ChangelogWeb.NewsAdController do
  use ChangelogWeb, :controller

  alias Changelog.{Hashid, NewsAd, NewsSponsorship}
  alias ChangelogWeb.NewsAdView

  def show(conn, %{"id" => slug}) do
    hashid = slug |> String.split("-") |> List.last

    ad =
      NewsAd
      |> Repo.get_by!(id: Hashid.decode(hashid))
      |> NewsAd.preload_sponsorship

    if slug == hashid do
      redirect(conn, to: news_ad_path(conn, :show, NewsAdView.slug(ad)))
    else
      render(conn, :show, ad: ad, sponsor: ad.sponsorship.sponsor)
    end
  end
end
