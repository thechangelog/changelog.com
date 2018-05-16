defmodule ChangelogWeb.NewsAdView do
  use ChangelogWeb, :public_view

  alias Changelog.{Files, Hashid}
  alias ChangelogWeb.{Endpoint, SponsorView}

  def admin_edit_link(conn, user, ad) do
    if user && user.admin do
      content_tag(:span, class: "news_item-toolbar-meta-item") do
        [
          link("[Edit]", to: admin_news_sponsorship_path(conn, :edit, ad.sponsorship, next: current_path(conn)), data: [turbolinks: false]),
          content_tag(:span, " (#{ad.click_count}/#{ad.impression_count})")
        ]
      end
    end
  end

  def hashid(ad), do: Hashid.encode(ad.id)

  def image_link(ad, version \\ :large) do
    if ad.image do
      content_tag :div, class: "news_item-image" do
        link to: ad.url do
          tag(:img, src: image_url(ad, version), alt: ad.headline)
        end
      end
    end
  end

  def image_path(ad, version) do
    {ad.image, ad}
    |> Files.Image.url(version)
    |> String.replace_leading("/priv", "")
  end

  def image_url(ad, version), do: static_url(Endpoint, image_path(ad, version))

  def render_toolbar_button(conn, ad = %{image: image}) when not is_nil(image) do
    render("toolbar/_button_image.html", conn: conn, ad: ad)
  end
  def render_toolbar_button(_conn, _ad), do: nil

  def slug(ad) do
    ad.headline
    |> String.downcase
    |> String.replace(~r/[^a-z0-9\s]/, "")
    |> String.replace(~r/\s+/, "-")
    |> Kernel.<>("-#{hashid(ad)}")
  end
end
