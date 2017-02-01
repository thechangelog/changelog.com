defmodule Changelog.HomeView do
  use Changelog.Web, :public_view

  alias Changelog.SharedView
  alias Changelog.{SharedView, PersonView}

  def checked_class_if(boolean) do
    if boolean do
      "checklist-item--checked"
    end
  end
end
