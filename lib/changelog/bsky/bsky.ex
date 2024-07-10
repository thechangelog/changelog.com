defmodule Changelog.Bsky do
  alias Changelog.Bsky.Client
  alias Changelog.{Episode, Snap, UrlKit}
  alias ChangelogWeb.EpisodeView

  def post(episode = %Episode{}) do
    episode = Episode.preload_podcast(episode)

    Client.create_post(
      text(episode),
      link(episode),
      title(episode),
      description(episode),
      img(episode)
    )
  end

  def text(episode) do
    "#{emoj()} #{ann(episode)} #{link(episode)}"
  end

  def link(episode) do
    episode |> EpisodeView.share_url() |> UrlKit.sans_scheme()
  end

  def title(episode) do
    episode |> EpisodeView.podcast_name_and_number()
  end

  def description(episode) do
    episode |> EpisodeView.text_description()
  end

  def img(episode) do
    img = Snap.img_url(episode)
    raw = UrlKit.get_body(img)
    {:ok, blob} = Client.create_blob(raw)
    blob
  end

  defp ann(%{podcast: %{slug: "podcast"}}) do
    "New Changelog interview!"
  end

  defp ann(%{podcast: %{slug: "shipit"}}) do
    "New episode of Ship It!"
  end

  defp ann(%{podcast: %{name: name}}) do
    "New episode of #{name}!"
  end

  defp emoj, do: ~w(🙌 🎉 🔥 💥 🚢 🚀 🥳 🤘) |> Enum.random()
end
