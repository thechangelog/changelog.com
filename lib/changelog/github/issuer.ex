defmodule Changelog.Github.Issuer do
  alias Changelog.Github.{Client, Source}

  @spec create(Source.t(), String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def create(source = %{repo: "transcripts"}, body) do
    title = "Parse error on #{source.name}"
    case Client.create_issue(source, title, body) do
      {:ok, %{status_code: 201}} -> {:ok, "Issue oepened"}
      {:ok, %{body: %{"message" => message}}} -> {:error, message}
      _else -> {:error, "Unknown error while opening issue #{source.path}"}
    end
  end
end
