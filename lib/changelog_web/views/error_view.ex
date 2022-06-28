defmodule ChangelogWeb.ErrorView do
  use ChangelogWeb, :public_view

  alias ChangelogWeb.SharedView

  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
