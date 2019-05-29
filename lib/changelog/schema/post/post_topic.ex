defmodule Changelog.PostTopic do
  use Changelog.Schema

  alias Changelog.{Topic, Post}

  schema "post_topics" do
    field :position, :integer
    field :delete, :boolean, virtual: true

    belongs_to :topic, Topic
    belongs_to :post, Post

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(position post_id topic_id delete)a)
    |> validate_required([:position])
    |> foreign_key_constraint(:post_id)
    |> foreign_key_constraint(:topic_id)
    |> mark_for_deletion()
  end
end
