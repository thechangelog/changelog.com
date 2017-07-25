defmodule Changelog.TranscriptFragment do
  use Ecto.Schema

  embedded_schema do
    field :title
    field :person_id, :integer
    field :body
  end
end

defmodule Changelog.Transcript do
  use Changelog.Web, :model

  alias Changelog.{Episode, TranscriptFragment}

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

  def update_fragments(transcript) do
    transcript = Repo.preload(transcript, :episode)
    participants = Episode.participants(transcript.episode)
    speaker_regex = ~r{\*\*(.*?):\*\*}

    fragments =
      speaker_regex
      |> Regex.split(transcript.raw, include_captures: true, trim: true)
      |> Enum.chunk(2)
      |> Enum.map(fn(tuple) ->
        [speaker_section, content_section] = tuple

        speaker_name = case Regex.run(speaker_regex, speaker_section) do
          [_, name] -> name
          nil -> "Unknown"
        end

        speaker_id = Enum.find_value(participants, fn(x) -> if x.name == speaker_name do x.id end end)

        content_section
        |> String.split("\n\n", trim: true)
        |> Enum.map(fn(line) ->
          %TranscriptFragment{title: speaker_name,
                              person_id: speaker_id,
                              body: String.trim(line)}
        end)
      end)
      |> List.flatten

    transcript
    |> change
    |> put_embed(:fragments, fragments)
    |> Repo.update!
  end
end
