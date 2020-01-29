defmodule ChangelogWeb.Admin.EpisodeRequestView do
  use ChangelogWeb, :admin_view

   alias ChangelogWeb.{PersonView}

   def description(request) do
    {:ok, date} = Timex.format(request.inserted_at, "{M}/{D}")
    "##{request.id}" <>
    " by " <>
    request.submitter.handle <>
    " (on #{date}) " <>
    pitch_preview(request, 60)
   end

   def pitch_preview(%{pitch: pitch}, count \\ 80) do
    pitch |> md_to_text() |> truncate(count)
   end

   def submitter_name(%{pronunciation: pronunciation}) do
    case pronunciation do
      nil -> "Anon"
      "" -> "Anon"
      _else -> pronunciation
    end
   end
end
