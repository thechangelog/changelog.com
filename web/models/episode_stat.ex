defmodule Changelog.EpisodeStat do
  use Changelog.Web, :model

  schema "episode_stats" do
    field :date, Timex.Ecto.Date
    field :episode_bytes, :integer
    field :total_bytes, :integer
    field :downloads, :float
    field :uniques, :integer
    field :demographics, :map

    belongs_to :episode, Changelog.Episode
    belongs_to :podcast, Changelog.Podcast
    timestamps
  end

  def newest_first(query, field \\ :date) do
    from e in query, order_by: [desc: ^field]
  end

  def changeset(episode_stat, params \\ %{}) do
    episode_stat
    |> cast(params, ~w(date episode_id podcast_id episode_bytes total_bytes downloads uniques demographics))
    |> validate_required([:date, :episode_id, :podcast_id])
  end
end
