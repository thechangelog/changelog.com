defmodule ChangelogWeb.Helpers.SharedHelpers do
  use Phoenix.HTML

  alias Changelog.StringKit
  alias Changelog.{ListKit, Regexp}
  alias Phoenix.{Controller, Naming}

  @doc """
  Returns `class_name` for a given connection if it matches any of the provided
  'matchers'. A 'matcher' could be a string representation of a controller/
  action combo, or it could be a regular expression.
  """
  def active_class(conn, matchers, class_name \\ "is-active")

  def active_class(conn, matchers, class_name) when is_binary(matchers),
    do: active_class(conn, [matchers], class_name)

  def active_class(conn, matchers, class_name) when is_list(matchers) do
    active_id = controller_action_combo(conn)

    if Enum.any?(matchers, fn x ->
         matcher = if is_struct(x, Regex), do: x, else: ~r/#{x}/
         String.match?(active_id, matcher)
       end) do
      class_name
    end
  end

  def action_name(conn), do: Controller.action_name(conn)

  def bsky_url(nil), do: ""
  def bsky_url(%{bsky_handle: nil}), do: ""
  def bsky_url(%{bsky_handle: handle}), do: bsky_url(handle)
  def bsky_url(handle), do: "https://bsky.app/profile/#{handle}"

  def comma_separated(number) do
    number
    |> Integer.to_charlist()
    |> Enum.reverse()
    |> Enum.chunk_every(3, 3, [])
    |> Enum.join(",")
    |> String.reverse()
  end

  def comma_separated_names(list)
  def comma_separated_names([first]), do: first.name
  def comma_separated_names([first, second]), do: "#{first.name} and #{second.name}"

  def comma_separated_names([first, second, third]),
    do: "#{first.name}, #{second.name}, and #{third.name}"

  def comma_separated_names([first | rest]), do: "#{first.name}, #{comma_separated_names(rest)}"
  def comma_separated_names(_unhandled), do: ""

  def controller_name(conn),
    do: Controller.controller_module(conn) |> Naming.resource_name("Controller")

  def controller_action_combo(conn),
    do: [controller_name(conn), action_name(conn)] |> Enum.join("-")

  def controller_action_combo_matches?(conn, list) when is_list(list) do
    combo = controller_action_combo(conn)
    Enum.any?(list, &(&1 == combo))
  end

  def ctr(%{impression_count: 0}), do: 0
  def ctr(%{click_count: 0}), do: 0

  def ctr(trackable) do
    Float.round(trackable.click_count / trackable.impression_count * 100, 1)
  end

  def current_path(conn), do: Controller.current_path(conn)
  def current_path(conn, params), do: Controller.current_path(conn, params)

  def dev_relative(url) do
    if Mix.env() == :dev do
      parsed = URI.parse(url)
      [parsed.path, parsed.fragment] |> ListKit.compact_join("#")
    else
      url
    end
  end

  def domain_name(url) do
    url
    |> URI.parse()
    |> Map.get(:host)
    |> String.replace(~r/\Awww\./, "")
  end

  def domain_url(url) do
    uri = URI.parse(url)
    "#{uri.scheme}://#{uri.host}"
  end

  def get_param(assigns, param, default \\ nil), do: Map.get(assigns.conn.params, param, default)

  def get_assigns_or_param(assigns, param, default \\ nil) do
    Map.get(assigns, String.to_atom(param)) || get_param(assigns, param, default)
  end

  def github_url(nil), do: ""
  def github_url(%{github_handle: nil}), do: ""
  def github_url(%{github_handle: handle}), do: github_url(handle)
  def github_url(handle), do: "https://github.com/#{handle}"

  def github_link(model) do
    if model.github_handle do
      link(model.github_handle, to: github_url(model.github_handle), rel: "external")
    end
  end

  def linkedin_url(nil), do: ""
  def linkedin_url(%{linkedin_handle: nil}), do: ""
  def linkedin_url(%{linkedin_handle: handle}), do: linkedin_url(handle)
  def linkedin_url(handle), do: "https://www.linkedin.com/in/#{handle}"

  def mastodon_url(nil), do: ""
  def mastodon_url(%{mastodon_handle: nil}), do: ""
  def mastodon_url(%{mastodon_handle: handle}), do: mastodon_url(handle)

  def mastodon_url(handle) do
    [user, domain] = String.split(handle, "@")
    "https://#{domain}/@#{user}"
  end

  def is_future?(time = %DateTime{}, as_of \\ Timex.now()), do: Timex.compare(time, as_of) == 1

  def is_past?(time = %DateTime{}, as_of \\ Timex.now()), do: Timex.compare(time, as_of) == -1

  def lazy_image(src, alt, attrs \\ []) do
    attrs = Keyword.merge(attrs, src: src, alt: alt, loading: "lazy")
    tag(:img, attrs)
  end

  def maybe_lazy_image(conn, src, alt, attrs \\ []) do
    case controller_name(conn) do
      "news_issue" -> tag(:img, Keyword.merge([src: src, alt: alt], attrs))
      _else -> lazy_image(src, alt, attrs)
    end
  end

  def md_to_safe_html(nil), do: ""
  def md_to_safe_html(md) when is_binary(md), do: Cmark.to_html(md, [:smart, :hardbreaks])

  def md_to_html(nil), do: ""

  def md_to_html(md) when is_binary(md) do
    # special case for years stated on their own, which are technically parsed as ordered list items
    # but we don't want them to be. eg - "1997." or "98."
    if String.match?(md, ~r/^\d{2,4}\.$/) do
      "<p>#{md}</p>"
    else
      Cmark.to_html(md, [:unsafe, :smart, :hardbreaks])
    end
  end

  def md_to_text(nil), do: ""

  def md_to_text(md) when is_binary(md), do: md |> StringKit.md_delinkify()

  def percent(_numerator, 0), do: 0
  def percent(numerator, divisor), do: (numerator / divisor * 100) |> round()

  def pluralize(list, singular, plural) when is_list(list),
    do: pluralize(length(list), singular, plural)

  def pluralize(1, singular, _plural), do: "1 #{singular}"
  def pluralize(count, _singular, plural), do: "#{count} #{plural}"

  def pretty_downloads(ep_or_pod) when is_map(ep_or_pod) do
    pretty_downloads(ep_or_pod.download_count)
  end

  def pretty_downloads(downloads), do: downloads |> round() |> comma_separated()

  def sans_p_tags(html), do: String.replace(html, Regexp.tag("p"), "")

  def sans_new_lines(string), do: String.replace(string, "\n", " ")

  def truncate(string, length) when is_binary(string) do
    if String.length(string) > length do
      String.slice(string, 0, length) <> "..."
    else
      string
    end
  end

  def truncate(_string, _length), do: ""

  def twitter_url(nil), do: ""
  def twitter_url(%{twitter_handle: nil}), do: ""
  def twitter_url(%{twitter_handle: handle}), do: twitter_url(handle)
  def twitter_url(handle) when is_binary(handle), do: "https://twitter.com/#{handle}"

  def twitter_link(model, string \\ nil) do
    if model.twitter_handle do
      link(string || model.twitter_handle, to: twitter_url(model.twitter_handle), rel: "external")
    end
  end

  def website_link(model) do
    if model.website do
      link(domain_name(model.website), to: model.website, rel: "external")
    end
  end

  def x_url(nil), do: ""
  def x_url(%{twitter_handle: nil}), do: ""
  def x_url(%{twitter_handle: handle}), do: x_url(handle)
  def x_url(handle) when is_binary(handle), do: "https://x.com/#{handle}"

  def word_count(nil), do: 0

  def word_count(text) when is_binary(text) do
    text |> md_to_text() |> String.split() |> length()
  end
end
