defmodule Changelog.TestCase do
  @moduledoc """
  Functions in this module are imported in all test modules
  """
  def fixtures_path do
    Path.dirname(__ENV__.file) <> "/../fixtures"
  end

  def fixtures_path(file_path) when is_binary(file_path) do
    fixtures_path() <> file_path
  end

  def stub_audio_file(episode) do
    %Changelog.Episode{episode | audio_file: %{file_name: "test.mp3"}}
  end

  @doc """
  Helper for retrying a test for `timeout` milliseconds before failing
  """
  def wait_for_passing(timeout, function) when timeout > 0 do
    function.()
  rescue
    _ ->
      Process.sleep(100)
      wait_for_passing(timeout - 100, function)
  end

  def wait_for_passing(_timeout, function), do: function.()
end
