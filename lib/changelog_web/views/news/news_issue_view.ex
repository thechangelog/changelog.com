defmodule ChangelogWeb.NewsIssueView do
  use ChangelogWeb, :public_view

  alias Changelog.{NewsItem, NewsAd}
  alias ChangelogWeb.{NewsItemView, PersonView, SponsorView}

  def items_with_ads(items, []), do: items
  def items_with_ads(items, ads) do
    items
    |> Enum.chunk_every(3)
    |> Enum.with_index()
    |> Enum.map(fn{items, index} ->
      case Enum.at(ads, index) do
        nil -> items
        ad -> items ++ [ad]
      end
    end)
    |> List.flatten()
  end

  def render_item_or_ad(ad = %NewsAd{}, assigns), do: render("_ad.html", Map.merge(assigns, %{ad: ad, sponsor: ad.sponsorship.sponsor}))
  def render_item_or_ad(item = %NewsItem{}, assigns) do
    case item.type do
      :audio -> render("_item_audio.html", Map.merge(assigns, %{item: NewsItem.load_object(item)}))
      _else -> render("_item.html", Map.merge(assigns, %{item: item}))
    end
  end

  def spacer_url do
    "https://changelog-assets.s3.amazonaws.com/weekly/spacer.gif"
  end
end
