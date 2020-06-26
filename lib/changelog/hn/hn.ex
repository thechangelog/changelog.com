defmodule Changelog.HN do
  alias Changelog.HN.Client

  def submit(%{feed_only: true}), do: false

  def submit(%{type: :audio, headline: title, url: url}) do
    Client.submit(title <> " [audio]", url)
  end

  def submit(%{headline: title, url: url}), do: Client.submit(title, url)
end
