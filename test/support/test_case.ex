defmodule Changelog.TestCase do
  @moduledoc """
  Functions in this module are imported in all test modules
  """
  def fixtures_path() do
    Path.dirname(__ENV__.file) <> "/../fixtures"
  end

  def stub_audio_file(episode) do
    %Changelog.Episode{episode | audio_file: %{file_name: "test.mp3"}}
  end
end
