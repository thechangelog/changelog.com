defmodule Changelog.Admin.PersonView do
  use Changelog.Web, :view

  def error_class(form, field) do
    if form.errors[field], do: "error", else: ""
  end
end
