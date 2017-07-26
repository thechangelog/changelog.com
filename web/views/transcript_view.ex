defmodule Changelog.TranscriptView do
  def fragment_permalink(fragment) do
    "##{fragment_short_id(fragment)}"
  end

  def fragment_short_id(fragment) do
    String.slice(fragment.id, 0..7)
  end
end
