defmodule ChangelogWeb.NewsIssueView do
  use ChangelogWeb, :public_view

  alias Changelog.{NewsItem, NewsAd}
  alias ChangelogWeb.{NewsItemView, SponsorView, PodcastView}

  def items_with_ads(items, []), do: items
  def items_with_ads(items, ads), do: items_with_ads(items, ads, 3)

  def items_with_ads(items, ads, every) do
    items
    |> Enum.chunk_every(every)
    |> Enum.with_index()
    |> Enum.map(fn {items, index} ->
      case Enum.at(ads, index) do
        nil -> items
        ad -> items ++ [ad]
      end
    end)
    |> List.flatten()
  end

  def render_item_or_ad(ad = %NewsAd{}, assigns) do
    render("_ad.html", Map.merge(assigns, %{ad: ad, sponsor: ad.sponsorship.sponsor}))
  end

  def render_item_or_ad(item = %NewsItem{}, assigns) do
    template =
      case item.type do
        :audio -> "_item_audio.html"
        _else -> "_item.html"
      end

    render(template, Map.merge(assigns, %{item: item}))
  end

  def spacer_url do
    "https://cdn.changelog.com/weekly/spacer.gif"
  end
end
