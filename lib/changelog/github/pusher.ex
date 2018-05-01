defmodule Changelog.Github.Pusher do

  alias Changelog.Github.Client

  def push(source, content) do
    if Client.file_exists?(source) do
      Client.edit_file(source, content, "Update #{source.name}")
    else
      Client.create_file(source, content, "Add #{source.name}")
    end
  end
end
