defmodule ChangelogWeb.NewsIssueView do
  use ChangelogWeb, :public_view

  alias Changelog.{NewsItem, NewsAd}
  alias ChangelogWeb.NewsItemView

  def items_with_ads(items, []), do: items
  def items_with_ads(items, ads) do
    items
    |> Enum.chunk_every(items_per_ad(items, ads))
    |> Enum.with_index
    |> Enum.map(fn{items, index} ->
      case Enum.at(ads, index) do
        nil -> items
        ad -> items ++ [ad]
      end
    end)
    |> List.flatten
  end

  defp items_per_ad(items, ads) do
    trunc(Float.ceil(length(items) / length(ads))) - 1
  end

  def render_item_or_ad(item = %NewsItem{}), do: render("_item.html", item: item)
  def render_item_or_ad(ad = %NewsAd{}), do: render("_ad.html", ad: ad)

  def spacer_url do
    "https://changelog-assets.s3.amazonaws.com/weekly/spacer.gif"
  end
end
