defmodule ChangelogWeb.NewsAdView do
  use ChangelogWeb, :public_view

  alias Changelog.{Files, HtmlKit, NewsAd}
  alias ChangelogWeb.{SponsorView}

  def admin_edit_link(conn, %{admin: true}, ad) do
    path =
      Routes.admin_news_sponsorship_path(conn, :edit, ad.sponsorship,
        next: SharedHelpers.current_path(conn)
      )

    content_tag(:span, class: "news_item-toolbar-meta-item") do
      [
        link("(#{ad.click_count}/#{ad.impression_count})", to: path)
      ]
    end
  end

  def admin_edit_link(_, _, _), do: nil

  def image_link(ad, version \\ :large) do
    if ad.image do
      content_tag :div, class: "news_item-image" do
        link to: ad.url, data: [news: true] do
          tag(:img, src: image_url(ad, version), alt: ad.headline)
        end
      end
    end
  end

  def image_url(ad, version), do: Files.Image.url({ad.image, ad}, version)

  def render_toolbar_button(_conn, _ad), do: nil

  def story_as_html(ad) do
    ad.story
    |> SharedHelpers.md_to_html()
    |> HtmlKit.put_sponsored()
  end
end
