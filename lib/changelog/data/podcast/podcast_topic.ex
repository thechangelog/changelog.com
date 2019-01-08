defmodule Changelog.PodcastTopic do
  use Changelog.Data

  alias Changelog.{Topic, Podcast}

  schema "podcast_topics" do
    field :position, :integer
    field :delete, :boolean, virtual: true

    belongs_to :podcast, Podcast
    belongs_to :topic, Topic

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(position podcast_id topic_id delete)a)
    |> validate_required([:position])
    |> mark_for_deletion()
  end
end
