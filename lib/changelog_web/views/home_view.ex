defmodule ChangelogWeb.HomeView do
  use ChangelogWeb, :public_view

  alias ChangelogWeb.{SharedView, PersonView}

  def checked_class_if(boolean) do
    if boolean do
      "checklist-item--checked"
    end
  end
end
