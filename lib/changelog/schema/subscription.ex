defmodule Changelog.Subscription do
  use Changelog.Schema

  alias Changelog.{Episode, NewsItem, Person, Podcast}

  schema "subscriptions" do
    field :unsubscribed_at, :utc_datetime
    field :context, :string

    belongs_to :episode, Episode
    belongs_to :item, NewsItem
    belongs_to :person, Person
    belongs_to :podcast, Podcast

    timestamps()
  end

  def subscribed(query \\ __MODULE__), do: from(q in query, where: is_nil(q.unsubscribed_at))

  def subscribed(query \\ __MODULE__, start_time, end_time) do
    from(q in query,
      where: is_nil(q.unsubscribed_at),
      where: q.inserted_at > ^start_time,
      where: q.inserted_at <= ^end_time
    )
  end

  def unsubscribed(query \\ __MODULE__),
    do: from(q in query, where: not is_nil(q.unsubscribed_at))

  def unsubscribed(query \\ __MODULE__, start_time, end_time) do
    from(q in query,
      where: not is_nil(q.unsubscribed_at),
      where: q.unsubscribed_at > ^start_time,
      where: q.unsubscribed_at <= ^end_time
    )
  end

  def for_person(query \\ __MODULE__, person),
    do: from(q in query, where: q.person_id == ^person.id)

  def on_episode(query \\ __MODULE__, episode),
    do: from(q in query, where: q.episode_id == ^episode.id)

  def on_item(query \\ __MODULE__, item), do: from(q in query, where: q.item_id == ^item.id)

  def on_podcast(query \\ __MODULE__, podcast),
    do: from(q in query, where: q.podcast_id == ^podcast.id)

  def on_subject(query, episode = %Episode{}), do: on_episode(query, episode)
  def on_subject(query, item = %NewsItem{}), do: on_item(query, item)
  def on_subject(query, podcast = %Podcast{}), do: on_podcast(query, podcast)

  def to_item(query \\ __MODULE__), do: from(q in query, where: not is_nil(q.item_id))

  def to_podcast(query \\ __MODULE__), do: from(q in query, where: not is_nil(q.podcast_id))

  def is_subscribed(%__MODULE__{unsubscribed_at: ts}), do: is_nil(ts)
  def is_subscribed(_), do: false

  def is_subscribed(person = %Person{}, to) do
    __MODULE__
    |> for_person(person)
    |> on_subject(to)
    |> subscribed()
    |> any?()
  end

  def is_unsubscribed(person = %Person{}, from) do
    __MODULE__
    |> for_person(person)
    |> on_subject(from)
    |> unsubscribed()
    |> any?()
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
    get_or_initialize_by(person, to)
    |> change(unsubscribed_at: nil)
    |> change(context: context)
    |> Repo.insert_or_update()
  end

  def subscribed_count(nil), do: 0

  def subscribed_count(subject) do
    __MODULE__
    |> on_subject(subject)
    |> subscribed()
    |> Repo.count()
  end

  def subscribed_count(subject, start_time, end_time) do
    __MODULE__
    |> on_subject(subject)
    |> subscribed(start_time, end_time)
    |> Repo.count()
  end

  def unsubscribed_count(subject) do
    __MODULE__
    |> on_subject(subject)
    |> unsubscribed()
    |> Repo.count()
  end

  def unsubscribed_count(subject, start_time, end_time) do
    __MODULE__
    |> on_subject(subject)
    |> unsubscribed(start_time, end_time)
    |> Repo.count()
  end

  def subscribed_to(%{item_id: id}) when not is_nil(id), do: Repo.get(NewsItem, id)
  def subscribed_to(%{podcast_id: id}) when not is_nil(id), do: Repo.get(Podcast, id)

  def unsubscribe(nil), do: false

  def unsubscribe(sub = %__MODULE__{}),
    do: sub |> change(unsubscribed_at: now_in_seconds()) |> Repo.update()

  def unsubscribe(nil, _subject), do: false

  def unsubscribe(person = %Person{}, subject) do
    get_or_initialize_by(person, subject)
    |> change(unsubscribed_at: now_in_seconds())
    |> Repo.insert_or_update()
  end

  defp get_or_initialize_by(person = %Person{}, subject) do
    attrs =
      case subject do
        %NewsItem{id: id} -> %{person_id: person.id, item_id: id}
        %Podcast{id: id} -> %{person_id: person.id, podcast_id: id}
        %Episode{id: id} -> %{person_id: person.id, episode_id: id}
      end

    case Repo.get_by(__MODULE__, attrs) do
      nil -> Map.merge(%__MODULE__{}, attrs)
      sub -> sub
    end
  end
end
