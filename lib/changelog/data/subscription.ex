defmodule Changelog.Subscription do
  use Changelog.Data

  alias Changelog.{NewsItem, Person, Podcast}

  schema "subscriptions" do
    field :unsubscribed_at, :utc_datetime

    belongs_to :person, Person
    belongs_to :podcast, Podcast
    belongs_to :news_item, NewsItem

    timestamps()
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [])
    |> validate_required([])
  end
end
