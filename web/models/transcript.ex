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

  def parse_raw(transcript) do
    transcript = Repo.preload(transcript, :episode)
    participants = Changelog.Episode.participants(transcript.episode)
    speaker_pattern = ~r{\*\*(.*?):\*\*}

    speaker_pattern
    |> Regex.split(transcript.raw, include_captures: true, trim: true)
    |> Enum.chunk(2)
    |> Enum.take(1) # temp
    |> Enum.each(fn(tuple) ->
      [speaker_section, content_section] = tuple

      speaker = case Regex.run(speaker_pattern, speaker_section) do
        [_, name] -> Enum.find(participants, fn(x) -> x.name == name end)
        nil -> nil
      end

      content_section
      |> String.split("\r\n\r\n", trim: true)
      |> Enum.each(fn(line) ->
        IO.puts "#{speaker.name} said: #{String.trim(line)}"
      end)
    end)

    transcript
  end
end
