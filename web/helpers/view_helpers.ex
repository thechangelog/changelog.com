defmodule Changelog.Helpers.ViewHelpers do
  use Phoenix.HTML

  defmacro __using__(_) do
    quote do
      import Changelog.Helpers.ViewHelpers
    end
  end

  def pagination_links(_one, _two, _three) do
    ""
  end

  def pagination_links(_one, _two, _three, _four) do
    ""
  end

  # moved here from PersonView because used pervasively
  def avatar_url(person), do: gravatar_url(person.email, 100)
  def avatar_url(person, size), do: gravatar_url(person.email, size)

  defp gravatar_url(email, size) do
    hash = email
      |> String.strip
      |> String.downcase
      |> :erlang.md5
      |> Base.encode16(case: :lower)

    "https://secure.gravatar.com/avatar/#{hash}.jpg?s=#{size}&d=mm"
  end

  def semantic_datetime_select(form, field, opts \\ []) do
    builder = fn b ->
      ~e"""
      <div class="fields">
        <div class="three wide field"><%= b.(:month, []) %></div>
        <div class="two wide field"><%= b.(:day, []) %></div>
        <div class="two wide field"><%= b.(:year, []) %></div> at
        <div class="two wide field"><%= b.(:hour, []) %></div>:
        <div class="two wide field"><%= b.(:min, []) %></div>&nbsp;UTC
      </div>
      """
    end

    datetime_select form, field, [builder: builder] ++ opts
  end

  def error_class(form, field) do
    if form.errors[field], do: "error", else: ""
  end

  def error_message(form, field) do
    if message = form.errors[field] do
      content_tag :div, class: "ui pointing red basic label" do
        message
      end
    end
  end

  def is_persisted(struct), do: is_integer(struct.id)

  def md_to_html(md) when is_binary(md), do: Cmark.to_html(md)
  def md_to_html(md) when is_nil(md), do: ""

  def md_to_text(md) when is_binary(md) do
    HtmlSanitizeEx.strip_tags(md_to_html(md))
  end
  def md_to_text(md) when is_nil(md), do: ""

  def external_link(text, opts) do
    link text, (opts ++ [rel: "external"])
  end

  def github_link(model) do
    if model.github_handle do
      external_link model.github_handle, to: "https://github.com/#{model.github_handle}"
    end
  end

  def twitter_link(model) do
    if model.twitter_handle do
      external_link model.twitter_handle, to: "https://twitter.com/#{model.twitter_handle}"
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
end
