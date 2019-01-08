defmodule Changelog.Subscription do
  use Changelog.Data

  alias Changelog.{NewsItem, Person, Podcast}

  schema "subscriptions" do
    field :unsubscribed_at, :utc_datetime

    belongs_to :person, Person
    belongs_to :podcast, Podcast
    belongs_to :item, NewsItem

    timestamps()
  end

  def subscribed(query \\ __MODULE__), do: from(q in query, where: is_nil(q.unsubscribed_at))
  def unsubscribed(query \\ __MODULE__), do: from(q in query, where: not(is_nil(q.unsubscribed_at)))

  def subscribe(person = %Person{}, to) do
    attrs = case to do
      %NewsItem{id: id} -> %{person_id: person.id, item_id: id}
      %Podcast{id: id} -> %{person_id: person.id, podcast_id: id}
    end

    case Repo.get_by(__MODULE__, attrs) do
      nil -> Map.merge(%__MODULE__{}, attrs)
      sub -> sub
    end
    |> change(unsubscribed_at: nil)
    |> Repo.insert_or_update()
  end

  def unsubscribe(person = %Person{}, from) do
    attrs = case from do
      %NewsItem{id: id} -> %{person_id: person.id, item_id: id}
      %Podcast{id: id} -> %{person_id: person.id, podcast_id: id}
    end

    sub = Repo.get_by(__MODULE__.subscribed, attrs)

    if sub do
      sub |> change(unsubscribed_at: now_in_seconds()) |> Repo.update()
    end

    :ok
  end
end
