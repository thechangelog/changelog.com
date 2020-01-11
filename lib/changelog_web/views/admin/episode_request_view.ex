defmodule ChangelogWeb.Admin.EpisodeRequestView do
  use ChangelogWeb, :admin_view

   alias ChangelogWeb.{PersonView}

   def status_label(%{status: :fresh}), do: ""
   def status_label(%{status: status}) do
    {color, label} = case status do
      :pending -> {"yellow", "Pending"}
      :declined -> {"grey", "Declined"}
    end

    content_tag :span, label, class: "ui tiny #{color} basic label"
   end

   def submitter_name(%{pronunciation: pronunciation}) do
    case pronunciation do
      nil -> "Anon"
      "" -> "Anon"
      _else -> pronunciation
    end
   end
end
