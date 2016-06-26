defmodule Changelog.TranscriptFragment do
  use Ecto.Schema

  embedded_schema do
    field :person_name
    field :person_id
    field :body
  end
end

defmodule Changelog.Transcript do
  use Changelog.Web, :model

  schema "transcripts" do
    field :raw, :string
    belongs_to :episode, Changelog.Episode
    embeds_many :fragments, Changelog.TranscriptFragment

    timestamps()
  end

  def admin_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(episode_id raw))
    |> validate_required([:episode_id, :raw])
  end
end
