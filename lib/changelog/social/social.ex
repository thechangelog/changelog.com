defmodule Changelog.Social do
  use ChangelogWeb, :verified_routes

  alias Changelog.Social.Client
  alias Changelog.NewsItem
  alias ChangelogWeb.NewsItemView

  # feed-only news items don't get posted
  def post(%NewsItem{feed_only: true}), do: false

  # episode news items don't get posted (for now)
  def post(%NewsItem{type: :audio}), do: false

  def post(item = %NewsItem{}) do
    item = NewsItem.preload_all(item)

    content = """
    #{headline(item)}
    #{author(item)}
    #{link(item)}
    """

    Client.create_status(content)
  end

  def post(_), do: false

  defp headline(item) do
    item.headline
  end

  defp author(%{author: nil}), do: nil
  defp author(%{author: %{mastodon_handle: nil}}), do: nil
  defp author(%{author: %{mastodon_handle: handle}}), do: "#{author_emoj()} by @#{handle}"

  defp link(item), do: "#{link_emoj()} #{link_url(item)}"

  defp author_emoj, do: ~w(✍️ 🖋 ✏️) |> Enum.random()
  defp link_emoj, do: ~w(✨ 💫 🔗 👉) |> Enum.random()

  defp link_url(item) do
    ~p"/news/#{NewsItemView.hashid(item)}"
  end
end
