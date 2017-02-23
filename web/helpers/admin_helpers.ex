defmodule Changelog.Helpers.AdminHelpers do
  use Phoenix.HTML

  alias Changelog.{Repo, TimeView}

  def channel_from_model_or_params(model, params) do
    (model |> Repo.preload(:channel)).channel ||
      Repo.get(Changelog.Channel, (Map.get(model, "channel_id") || params["channel_id"]))
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
    <div class="ui section divider"></div>
    <button class="ui primary basic button" type="submit">Save</button>
    <button class="ui secondary basic button" type="submit" name="close">Save and Close</button>
    """
  end

  def help_icon(help_text) do
    ~e"""
    <i class="help circle icon fluid" data-popup="true" data-variation="wide" data-content="<%= help_text %>"></i>
    """
  end

  def is_persisted(struct), do: is_integer(struct.id)

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
