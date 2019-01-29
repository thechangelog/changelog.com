defmodule Changelog.Transcripts.Parser do
  @speaker_regex ~r{\*\*(.*?):\*\*}

  def parse_text(string, participants \\ [])
  def parse_text(string, participants) when is_nil(string), do: parse_text("", participants)
  def parse_text(string, participants) do
    @speaker_regex
    |> Regex.split(string, include_captures: true, trim: true)
    |> Enum.chunk_every(2)
    |> Enum.map(fn(tuple) ->
      [speaker_section, content_section] = tuple

      speaker_name = case Regex.run(@speaker_regex, speaker_section) do
        [_, name] -> name
        nil -> "Unknown"
      end

      speaker_id = Enum.find_value(participants, fn(x) -> if x.name == speaker_name do x.id end end)

      %{title: speaker_name,
        person_id: speaker_id,
        body: String.trim(content_section)}
    end)
    |> List.flatten
  end
end
