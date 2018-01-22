defmodule ChangelogWeb.Helpers.SharedHelpers do
  use Phoenix.HTML

  alias Changelog.Regexp
  alias Phoenix.{Controller, Naming}

  def active_class(conn, controllers, class_name \\ "is-active")
  def active_class(conn, controllers, class_name) when is_binary(controllers), do: active_class(conn, [controllers], class_name)
  def active_class(conn, controllers, class_name) when is_list(controllers) do
    active_id = controller_action_combo(conn)

    if Enum.any?(controllers, fn(x) -> String.match?(active_id, ~r/#{x}/) end) do
      class_name
    end
  end

  def action_name(conn), do: Controller.action_name(conn)

  def comma_separated(number) do
    number
    |> Integer.to_charlist
    |> Enum.reverse
    |> Enum.chunk(3, 3, [])
    |> Enum.join(",")
    |> String.reverse
  end

  def controller_name(conn), do: Controller.controller_module(conn) |> Naming.resource_name("Controller")
  def controller_action_combo(conn), do: [controller_name(conn), action_name(conn)] |> Enum.join("-")

  def current_path(conn), do: Controller.current_path(conn)
  def current_path(conn, params), do: Controller.current_path(conn, params)

  def dev_relative(url) do
    if Mix.env == :dev do
      URI.parse(url).path
    else
      url
    end
  end

  def domain_name(url) do
    uri = URI.parse(url)
    uri.host
  end

  def domain_url(url) do
    uri = URI.parse(url)
    "#{uri.scheme}://#{uri.host}"
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

  def twitter_url(handle) when is_binary(handle), do: "https://twitter.com/#{handle}"
  def twitter_url(person), do: "https://twitter.com/#{person.handle}"

  def twitter_link(model, string \\ nil) do
    if model.twitter_handle do
      external_link (string || model.twitter_handle), to: twitter_url(model.twitter_handle)
    end
  end

  def website_link(model) do
    if model.website do
      external_link domain_name(model.website), to: model.website
    end
  end

  def pluralize(list, singular, plural) when is_list(list), do: pluralize(length(list), singular, plural)
  def pluralize(1, singular, _plural), do: "1 #{singular}"
  def pluralize(count, _singular, plural), do: "#{count} #{plural}"
end
