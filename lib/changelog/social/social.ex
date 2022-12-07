defmodule Changelog.Social do
  alias Changelog.Social.Client
  alias Changelog.NewsItem
  alias ChangelogWeb.{Endpoint, NewsItemView}
  alias ChangelogWeb.Router.Helpers, as: Routes

  # feed-only news items don't get posted
  def post(%NewsItem{feed_only: true}), do: false

  # episode news items don't get posted (for now)
  def post(%NewsItem{type: :audio}), do: false

  def post(item = %NewsItem{}) do
    contents = """
    #{headline(item)}

    #{link_emoj()} #{link_url(item)}
    """

    Client.create_status(contents)
  end

  def post(_), do: false

  defp headline(item) do
    item.headline
  end

  defp link_emoj, do: ~w(🔗 ✍️ 🖋) |> Enum.random()

  defp link_url(item) do
    Routes.news_item_url(Endpoint, :show, NewsItemView.hashid(item))
  end
end
