defmodule Changelog.FeedStat do
  use Changelog.Schema, default_sort: :date

  alias Changelog.{Feed, Podcast}

  schema "feed_stats" do
    field :date, :date
    field :agents, :map

    belongs_to :feed, Feed
    belongs_to :podcast, Podcast

    timestamps()
  end

  def between(query \\ __MODULE__, start_date, end_date),
    do: from(q in query, where: q.date < ^end_date, where: q.date >= ^start_date)

  def on_date(query \\ __MODULE__, date), do: from(q in query, where: q.date == ^date)

  def next_after(query \\ __MODULE__, stat),
    do: from(q in query, where: q.date > ^stat.date)

  def previous_to(query \\ __MODULE__, stat),
    do: from(q in query, where: q.date < ^stat.date)

  def oldest_date do
    Repo.one(from s in __MODULE__, select: [min(s.date)], limit: 1)
    |> List.first()
  end

  def changeset(stat, attrs \\ %{}) do
    stat
    |> cast(
      attrs,
      ~w(date feed_id podcast_id agents)a
    )
    |> validate_required([:date])
    |> foreign_key_constraint(:feed_id)
    |> foreign_key_constraint(:podcast_id)
  end
end
