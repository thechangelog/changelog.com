defmodule ChangelogWeb.Helpers.SharedHelpers do
  use Phoenix.HTML

  alias Changelog.Regexp

  def comma_separated(number) do
    number
    |> Integer.to_charlist
    |> Enum.reverse
    |> Enum.chunk(3, 3, [])
    |> Enum.join(",")
    |> String.reverse
  end

  def domain_only(url) do
    uri = URI.parse(url)
    uri.host
  end

  def external_link(text, opts) do
    link text, (opts ++ [rel: "external"])
  end

  def github_url(handle), do: "https://github.com/#{handle}"

  def github_link(model) do
    if model.github_handle do
      external_link model.github_handle, to: github_url(model.github_handle)
    end
  end

  def md_to_safe_html(md) when is_binary(md), do: Cmark.to_html(md, [:safe])
  def md_to_safe_html(md) when is_nil(md), do: ""

  def md_to_html(md) when is_binary(md), do: Cmark.to_html(md)
  def md_to_html(md) when is_nil(md), do: ""

  def md_to_text(md) when is_binary(md), do: HtmlSanitizeEx.strip_tags(md_to_html(md))
  def md_to_text(md) when is_nil(md), do: ""

  def sans_p_tags(html), do: String.replace(html, Regexp.tag("p"), "")

  def twitter_url(handle), do: "https://twitter.com/#{handle}"

  def twitter_link(model, string \\ nil) do
    if model.twitter_handle do
      external_link (string || model.twitter_handle), to: twitter_url(model.twitter_handle)
    end
  end

  def website_link(model) do
    if model.website do
      external_link domain_only(model.website), to: model.website
    end
  end

  def pluralize(list, singular, plural) when is_list(list), do: pluralize(length(list), singular, plural)
  def pluralize(1, singular, _plural), do: "1 #{singular}"
  def pluralize(count, _singular, plural), do: "#{count} #{plural}"
end
