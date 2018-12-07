defmodule Changelog.Github.Pusher do

  alias Changelog.Github.{Client, Source}

  @spec push(Source.t, String.t) :: {:ok, String.t} | {:error, String.t}
  def push(source, nil), do: {:error, "Cannot push empty content to #{source.path}"}
  def push(source, content) do
    if Client.file_exists?(source) do
      edit_file(source, content)
    else
      create_file(source, content)
    end
  end

  defp edit_file(source, content) do
    case Client.edit_file(source, content, "Update #{source.name}") do
      {:ok, %{status_code: 200}} -> {:ok, "Updated #{source.path}"}
      {:ok, %{body: %{"message" => message}}} -> {:error, message}
      _else -> {:error, "Unknown error while updating #{source.path}"}
    end
  end

  defp create_file(source, content) do
    case Client.create_file(source, content, "Add #{source.name}") do
      {:ok, %{status_code: 201}} -> {:ok, "Added #{source.path}"}
      {:ok, %{body: %{"message" => message}}} -> {:error, message}
      _else -> {:error, "Unknown error while adding #{source.path}"}
    end
  end
end
