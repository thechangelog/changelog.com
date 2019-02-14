defmodule Changelog.Subscription do
  use Changelog.Data

  alias Changelog.{NewsItem, Person, Podcast}

  schema "subscriptions" do
    field :unsubscribed_at, :utc_datetime
    field :context, :string

    belongs_to :person, Person
    belongs_to :podcast, Podcast
    belongs_to :item, NewsItem

    timestamps()
  end

  def on_item(query \\ __MODULE__, item), do: from(q in query, where: q.item_id == ^item.id)
  def on_podcast(query \\ __MODULE__, podcast), do: from(q in query, where: q.podcast_id == ^podcast.id)
  def subscribed(query \\ __MODULE__), do: from(q in query, where: is_nil(q.unsubscribed_at))
  def unsubscribed(query \\ __MODULE__), do: from(q in query, where: not(is_nil(q.unsubscribed_at)))

  def is_subscribed(%__MODULE__{unsubscribed_at: ts}), do: is_nil(ts)
  def is_subscribed(_), do: false

  # this is a lot like unsubscribe/2 only it won't no-op if person isn't subbed yet
  def mute(person = %Person{}, item = %NewsItem{}) do
    attrs = %{person_id: person.id, item_id: item.id}

    case Repo.get_by(__MODULE__, attrs) do
      nil -> Map.merge(%__MODULE__{}, attrs)
      sub -> sub
    end
    |> change(unsubscribed_at: now_in_seconds())
    |> Repo.insert_or_update()
  end

  def preload_all(sub) do
    sub
    |> preload_item()
    |> preload_person()
    |> preload_podcast()
  end

  def preload_item(query = %Ecto.Query{}), do: Ecto.Query.preload(query, :item)
  def preload_item(sub), do: Repo.preload(sub, :item)

  def preload_person(query = %Ecto.Query{}), do: Ecto.Query.preload(query, :person)
  def preload_person(sub), do: Repo.preload(sub, :person)

  def preload_podcast(query = %Ecto.Query{}), do: Ecto.Query.preload(query, :podcast)
  def preload_podcast(sub), do: Repo.preload(sub, :podcast)

  def subscribe(person = %Person{}, to, context \\ "") do
    attrs = case to do
      %NewsItem{id: id} -> %{person_id: person.id, item_id: id}
      %Podcast{id: id} -> %{person_id: person.id, podcast_id: id}
    end

    case Repo.get_by(__MODULE__, attrs) do
      nil -> Map.merge(%__MODULE__{}, attrs)
      sub -> sub
    end
    |> change(unsubscribed_at: nil)
    |> change(context: context)
    |> Repo.insert_or_update()
  end

  def subscribed_count(item = %NewsItem{}) do
    item
    |> on_item()
    |> subscribed()
    |> Repo.count()
  end
  def subscribed_count(podcast = %Podcast{}) do
    podcast
    |> on_podcast()
    |> subscribed()
    |> Repo.count()
  end

  def unsubscribed_count(item = %NewsItem{}) do
    item
    |> on_item()
    |> unsubscribed()
    |> Repo.count()
  end
  def unsubscribed_count(podcast = %Podcast{}) do
    podcast
    |> on_podcast()
    |> unsubscribed()
    |> Repo.count()
  end

  def subscribed_to(%{item_id: id}) when not is_nil(id), do: Repo.get(NewsItem, id)
  def subscribed_to(%{podcast_id: id}) when not is_nil(id), do: Repo.get(Podcast, id)

  def unsubscribe(nil), do: false
  def unsubscribe(sub = %__MODULE__{}), do: sub |> change(unsubscribed_at: now_in_seconds()) |> Repo.update()
  def unsubscribe(person = %Person{}, from) do
    attrs = case from do
      %NewsItem{id: id} -> %{person_id: person.id, item_id: id}
      %Podcast{id: id} -> %{person_id: person.id, podcast_id: id}
    end

    __MODULE__.subscribed()
    |> Repo.get_by(attrs)
    |> unsubscribe()
  end
end
