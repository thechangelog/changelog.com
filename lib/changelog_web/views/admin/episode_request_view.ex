defmodule ChangelogWeb.Admin.EpisodeRequestView do
  use ChangelogWeb, :admin_view

   alias ChangelogWeb.{PersonView}

   def submitter_name(%{pronunciation: pronunciation}) do
    case pronunciation do
      nil -> "Anon"
      "" -> "Anon"
      _else -> pronunciation
    end
   end
end
