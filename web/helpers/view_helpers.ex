defmodule Changelog.Helpers.ViewHelpers do
  use Phoenix.HTML

  defmacro __using__(_) do
    quote do
      import Changelog.Helpers.ViewHelpers
    end
  end

  def comma_separated(number) do
    number
    |> Integer.to_char_list
    |> Enum.reverse
    |> Enum.chunk(3, 3, [])
    |> Enum.join(",")
    |> String.reverse
  end

  def domain_only(url) do
    uri = URI.parse(url)
    uri.host
  end

  def error_class(form, field) do
    if form.errors[field], do: "error", else: ""
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
  def plural_form(1, singular, _plural), do: singular
  def plural_form(_count, _singular, plural), do: plural

  def pluralize(list, singular, plural) when is_list(list), do: pluralize(length(list), singular, plural)
  def pluralize(1, singular, _plural), do: "1 #{singular}"
  def pluralize(count, _singular, plural), do: "#{count} #{plural}"

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
      external_link domain_only(model.website), to: model.website
    end
  end

  def tweet_url(text, url, via \\ "changelog")
  def tweet_url(text, url, nil), do: tweet_url(text, url)
  def tweet_url(text, url, via) do
    text = URI.encode(text)
    related = ["changelog", via] |> List.flatten |> Enum.uniq |> Enum.join(",")
    "https://twitter.com/intent/tweet?text=#{text}&url=#{url}&via=#{via}&related=#{related}"
  end

  def reddit_url(title, url) do
    title = URI.encode(title)
    "http://www.reddit.com/submit?url=#{url}&title=#{title}"
  end

  def hackernews_url(title, url) do
    title = URI.encode(title)
    "http://news.ycombinator.com/submitlink?u=#{url}&t=#{title}"
  end

  def facebook_url(url) do
    "https://www.facebook.com/sharer/sharer.php?u=#{url}"
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
  def ts(ts) do
    {:ok, formatted} = Timex.format(ts, "{ISO:Extended}")
    {:safe, "<span class='time'>#{formatted}</span>"}
  end

  def with_smart_quotes(string) do
    string
    |> String.replace_leading("\"", "“")
    |> String.replace_trailing("\"", "”")
  end
end
