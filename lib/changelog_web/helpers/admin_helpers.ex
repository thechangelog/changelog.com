defmodule ChangelogWeb.Helpers.AdminHelpers do
  use Phoenix.HTML

  alias Changelog.Repo
  alias ChangelogWeb.{TimeView}

  def error_class(form, field) do
    if form.errors[field], do: "error", else: ""
  end

  def error_message(form, field) do
    case form.errors[field] do
      {message, _} ->
        content_tag :div, class: "ui pointing red basic label" do
          message
        end
      nil -> ""
    end
  end

  def form_actions() do
    ~e"""
    <div class="ui hidden divider"></div>
    <div class="ui equal width stackable grid">
    <div class="column"><button class="ui primary fluid basic button" type="submit">Save</button></div>
    <div class="column"><button class="ui secondary fluid basic button" type="submit" name="close">Save and Close</button></div>
    <div class="column"></div>
    """
  end

  def help_icon(help_text) do
    ~e"""
    <i class="help circle icon fluid" data-popup="true" data-variation="wide" data-content="<%= help_text %>"></i>
    """
  end

  def icon_link(icon_name, options) do
    options = Keyword.put(options, :class, "ui icon button")
    link content_tag(:i, "", class: "#{icon_name} icon"), options
  end

  def is_persisted(struct), do: is_integer(struct.id)

  def is_loaded(nil), do: false
  def is_loaded(%Ecto.Association.NotLoaded{}), do: false
  def is_loaded(_association), do: true

  # Attempts to load an associated record on a form. Starts with direct
  # relationship on form data, then tries querying Repo.
  def load_from_form(form, module, relationship) do
    form_data = Map.get(form.data, relationship)
    foreign_key = "#{relationship}_id"
    record_id = Map.get(form.data, String.to_atom(foreign_key)) || form.params[foreign_key]

    cond do
      is_loaded(form_data) -> form_data
      is_nil(record_id) -> nil
      true -> Repo.get(module, record_id)
    end
  end

  def semantic_calendar_field(form, field) do
    ~e"""
    <div class="ui calendar">
      <div class="ui input left icon">
        <i class="calendar icon"></i>
        <%= text_input(form, field, name: "", id: "") %>
        <%= hidden_input(form, field) %>
      </div>
    </div>
    """
  end

  def truncate(string, length) when is_binary(string) do
    if String.length(string) > length do
      String.slice(string, 0, length) <> "..."
    else
      string
    end
  end
  def truncate(_string, _length), do: ""

  def ts(ts), do: TimeView.ts(ts)
end
