defmodule ChangelogWeb.NewsAdControllerTest do
  use ChangelogWeb.ConnCase

  alias Changelog.{Hashid, NewsAd}
  alias ChangelogWeb.NewsAdView

  test "getting a news ad page via hashid", %{conn: conn} do
    ad = insert(:news_ad, headline: "Hash ID 4 EVA!")
    hashid = Hashid.encode(ad.id)
    conn = get(conn, news_ad_path(conn, :show, hashid))
    assert redirected_to(conn) == news_ad_path(conn, :show, NewsAdView.slug(ad))
  end

  test "getting a news ad page via full slug", %{conn: conn} do
    ad = insert(:news_ad, headline: "You gonna like this")
    conn = get(conn, news_ad_path(conn, :show, NewsAdView.slug(ad)))
    assert html_response(conn, 200) =~ ad.headline
  end

  test "hitting the impress endpoint", %{conn: conn} do
    ad = insert(:news_ad, headline: "You gonna like this")
    conn = get(conn, news_ad_path(conn, :impress, NewsAdView.slug(ad)))
    assert conn.status == 200
    ad = Repo.get(NewsAd, ad.id) |> NewsAd.preload_sponsorship
    assert ad.impression_count == 1
    assert ad.sponsorship.impression_count == 1
  end

  test "hitting the visit endpoint", %{conn: conn} do
    ad = insert(:news_ad, headline: "You gonna like this")
    conn = get(conn, news_ad_path(conn, :visit, NewsAdView.slug(ad)))
    assert redirected_to(conn) == ad.url
    ad = Repo.get(NewsAd, ad.id) |> NewsAd.preload_sponsorship
    assert ad.click_count == 1
    assert ad.sponsorship.click_count == 1
  end
end
