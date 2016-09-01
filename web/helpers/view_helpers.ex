defmodule Changelog.Helpers.ViewHelpers do
  use Phoenix.HTML

  defmacro __using__(_) do
    quote do
      import Changelog.Helpers.ViewHelpers
    end
  end

  def external_link(text, opts) do
    link text, (opts ++ [rel: "external"])
  end

  def md_to_html(md) when is_binary(md), do: Cmark.to_html(md)
  def md_to_html(md) when is_nil(md), do: ""

  def md_to_text(md) when is_binary(md) do
    HtmlSanitizeEx.strip_tags(md_to_html(md))
  end
  def md_to_text(md) when is_nil(md), do: ""

  def no_widowed_words(string) when is_nil(string), do: no_widowed_words("")
  def no_widowed_words(string) do
    words = String.split(string, " ")

    case length(words) do
      0   -> ""
      1   -> string
      len ->
        first = Enum.take(words, len - 1) |> Enum.join(" ")
        last = List.last(words)
        [first, last] |> Enum.join("&nbsp;")
    end
  end

  def plural_form(list, singular, plural) when is_list(list), do: plural_form(length(list), singular, plural)
  def plural_form(count, singular, plural) do
    if count == 1 do
      singular
    else
      plural
    end
  end

  def pluralize(list, singular, plural) when is_list(list), do: pluralize(length(list), singular, plural)
  def pluralize(count, singular, plural) do
    if count == 1 do
      "#{count} #{singular}"
    else
      "#{count} #{plural}"
    end
  end

  def sans_p_tags(html), do: String.replace(html, ~r/<\/?p>/, "")

  def github_url(handle), do: "https://github.com/#{handle}"
  def twitter_url(handle), do: "https://twitter.com/#{handle}"

  def github_link(model) do
    if model.github_handle do
      external_link model.github_handle, to: github_url(model.github_handle)
    end
  end

  def twitter_link(model, string \\ nil) do
    if model.twitter_handle do
      external_link (string || model.twitter_handle), to: twitter_url(model.twitter_handle)
    end
  end

  def website_link(model) do
    if model.website do
      external_link model.website, to: model.website
    end
  end

  def truncate(string, length) when is_binary(string) do
    if String.length(string) > length do
      String.slice(string, 0, length) <> "..."
    else
      string
    end
  end
  def truncate(_string, _length), do: ""

  def ts(ts) when is_nil(ts), do: ""
  def ts(ts), do: {:safe, "<span class='time'>#{Ecto.DateTime.to_iso8601(ts)}</span>"}

  def with_smart_quotes(string) do
    string
    |> String.replace_leading("\"", "“")
    |> String.replace_trailing("\"", "”")
  end
end
