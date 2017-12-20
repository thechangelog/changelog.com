defmodule ChangelogWeb.NewsItemView do
  use ChangelogWeb, :public_view

  alias Changelog.{Files, NewsAd, NewsItem, Regexp}

  def image_url(item, version) do
    Files.Image.url({item.image, item}, version)
    |> String.replace_leading("/priv", "")
  end

  def render_item_or_ad(item = %NewsItem{}), do: render("_item.html", item: item)
  def render_item_or_ad(ad = %NewsAd{}), do: render("_ad.html", ad: ad)

  def teaser(story, max_words \\ 20) do
    word_count = story |> md_to_text |> String.split |> length

    story
    |> md_to_html
    |> prepare_html
    |> String.split
    |> truncate(word_count, max_words)
    |> Enum.join(" ")
  end

  defp prepare_html(html) do
    html
    |> String.replace("\n", " ") # treat news lines as spaces
    |> String.replace(Regexp.tag("p"), "") # remove p tags
    |> String.replace(~r/(<\w+>)\s+(\S)/, "\\1\\2" ) # attach open tags to next word
    |> String.replace(~r/(\S)\s+(<\/\w+>)/, "\\1\\2" ) # attach close tags to prev word
    |> String.replace(Regexp.tag("blockquote"), "\\1i\\2") # treat as italics
  end

  defp truncate(html_list, total_words, max_words) when total_words <= max_words, do: html_list
  defp truncate(html_list, _total_words, max_words) do
    sliced = Enum.slice(html_list, 0..(max_words-1))
    tags = Regex.scan(Regexp.tag, Enum.join(sliced, " "), capture: ["tag"]) |> List.flatten

    sliced ++ case Integer.mod(length(tags), 2) do
      0 -> ["..."]
      1 -> ["</#{List.last(tags)}>", "..."]
    end
  end
end
