defmodule ChangelogWeb.Admin.EpisodeRequestView do
  use ChangelogWeb, :admin_view

  alias Changelog.{Episode, StringKit}
  alias ChangelogWeb.{PersonView}
  alias ChangelogWeb.Admin.{EpisodeView, PodcastView}

  def credit(%{pronunciation: pronunciation}) do
    if StringKit.present?(pronunciation) do
      "Name is pronounced: #{pronunciation}"
    else
      "Submitter would like to remain anonymous"
    end
  end

  def description(request) do
    {:ok, date} = Timex.format(request.inserted_at, "{M}/{D}")

    "##{request.id}" <>
      " by " <>
      request.submitter.handle <>
      " (on #{date}) " <>
      SharedHelpers.truncate(request.topics, 60)
  end

  def podcast_options do
    Changelog.Cache.active_podcasts() |> Enum.map(&{&1.name, &1.id})
  end

  def pitch_preview(%{pitch: pitch}, count \\ 80) do
    pitch |> SharedHelpers.md_to_text() |> SharedHelpers.truncate(count)
  end

  def status_label(%{episode: episode}) when is_map(episode) do
    if Episode.is_public(episode) do
      content_tag(:span, "Complete", class: "ui tiny blue basic label")
    else
      content_tag(:span, "Accepted", class: "ui tiny yellow basic label")
    end
  end

  def status_label(request) do
    case request.status do
      :fresh -> content_tag(:span, "Fresh", class: "ui tiny green basic label")
      :declined -> content_tag(:span, "Declined", class: "ui tiny basic label")
      :pending -> content_tag(:span, "Pending", class: "ui tiny yellow basic label")
      :failed -> content_tag(:span, "Failed", class: "ui tiny basic label")
    end
  end

  def submitter_name(%{pronunciation: pronunciation}) do
    if StringKit.present?(pronunciation) do
      pronunciation
    else
      "Anon"
    end
  end
end
