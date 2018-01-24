defmodule ChangelogWeb.NewsAdControllerTest do
  use ChangelogWeb.ConnCase

  import ChangelogWeb.NewsAdView, only: [hashid: 1, slug: 1]

  alias Changelog.NewsAd

  test "getting a news ad page via hashid", %{conn: conn} do
    ad = insert(:news_ad, headline: "Hash ID 4 EVA!")
    hashid = hashid(ad)
    conn = get(conn, news_ad_path(conn, :show, hashid))
    assert redirected_to(conn) == news_ad_path(conn, :show, slug(ad))
  end

  test "getting a news ad page via full slug", %{conn: conn} do
    ad = insert(:news_ad, headline: "You gonna like this")
    conn = get(conn, news_ad_path(conn, :show, slug(ad)))
    assert html_response(conn, 200) =~ ad.headline
  end

  test "hitting the impress endpoint", %{conn: conn} do
    ad1 = insert(:news_ad, headline: "You gonna like this")
    ad2 = insert(:news_ad, headline: "You gonna like this too")
    conn = post(conn, news_ad_path(conn, :impress), ads: "#{hashid(ad1)},#{hashid(ad2)}")
    assert conn.status == 200
    ad1 = Repo.get(NewsAd, ad1.id) |> NewsAd.preload_sponsorship
    ad2 = Repo.get(NewsAd, ad2.id) |> NewsAd.preload_sponsorship
    assert ad1.impression_count == 1
    assert ad1.sponsorship.impression_count == 1
    assert ad2.impression_count == 1
    assert ad2.sponsorship.impression_count == 1
  end

  test "hitting the visit endpoint", %{conn: conn} do
    ad = insert(:news_ad, headline: "You gonna like this")
    conn = get(conn, news_ad_path(conn, :visit, hashid(ad)))
    assert redirected_to(conn) == ad.url
    ad = Repo.get(NewsAd, ad.id) |> NewsAd.preload_sponsorship
    assert ad.click_count == 1
    assert ad.sponsorship.click_count == 1
  end
end
