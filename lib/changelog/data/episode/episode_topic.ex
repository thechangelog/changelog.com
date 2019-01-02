defmodule Changelog.EpisodeTopic do
  use Changelog.Data

  alias Changelog.{Topic, Episode}

  schema "episode_topics" do
    field :position, :integer
    field :delete, :boolean, virtual: true

    belongs_to :topic, Topic
    belongs_to :episode, Episode

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(position episode_id topic_id delete)a)
    |> validate_required([:position])
    |> mark_for_deletion()
  end

  def build_and_preload({topic, position}) do
    %__MODULE__{position: position, topic_id: topic.id} |> Repo.preload(:topic)
  end
end
