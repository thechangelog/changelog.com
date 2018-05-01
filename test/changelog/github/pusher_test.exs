defmodule Changelog.Github.PusherTest do
  use Changelog.DataCase

  import Mock

  alias Changelog.Github.{Client, Pusher}

  def source_for_path(path) do
    %{org: "thechangelog", repo: "show-notes", name: "The Changelog #12", path: path}
  end

  describe "push" do
    test "when the path already exists" do
      source = source_for_path("gotime/go-time-1.md")
      content = "these are my show notes"

      with_mock(Client, [file_exists?: fn(_) -> true end, edit_file: fn(_, _, _) -> %{} end]) do
        Pusher.push(source, content)
        assert called(Client.file_exists?(source))
        assert called(Client.edit_file(source, content, "Update The Changelog #12"))
      end
    end

    test "when the path doesn't exist yet" do
      source = source_for_path("gotime/go-time-1.md")
      content = "these are my show notes"

      with_mock(Client, [file_exists?: fn(_) -> false end, create_file: fn(_, _, _) -> %{} end]) do
        Pusher.push(source, content)
        assert called(Client.file_exists?(source))
        assert called(Client.create_file(source, content, "Add The Changelog #12"))
      end
    end
  end
end
