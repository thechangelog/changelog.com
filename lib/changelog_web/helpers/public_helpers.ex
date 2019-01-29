defmodule ChangelogWeb.Helpers.PublicHelpers do
  use Phoenix.HTML

  alias Changelog.{Person, Regexp}

  def auth_link_expires_in(person) do
    person.auth_token_expires_at
    |> Timex.diff(Timex.now(), :duration)
    |> Timex.Duration.to_minutes()
    |> round()
    |> Timex.Duration.from_minutes()
    |> Timex.format_duration(:humanized)
  end

  def error_class(form, field) do
    if form.errors[field], do: "error", else: ""
  end

  def error_message(form, field) do
    case form.errors[field] do
      {message, _} ->
        content_tag :p, class: "form-element-error" do
          message
        end
      nil -> ""
    end
  end

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

  def user_required_options(%Person{}, options), do: options
  def user_required_options(_else, options), do: options ++ [disabled: true]

  def with_smart_quotes(string) do
    string
    |> String.replace_leading("\"", "“")
    |> String.replace_trailing("\"", "”")
  end

  def with_timestamp_links(string) do
    String.replace(string, Regexp.timestamp, ~S{<a class="timestamp" href="#t=\0">\0</a>})
  end
end
