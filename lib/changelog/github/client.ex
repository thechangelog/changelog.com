defmodule Changelog.Github.Client do
  use HTTPoison.Base

  def process_url(url), do: "https://api.github.com#{url}"

  def process_response_body(body) do
    try do
      Poison.decode!(body)
    rescue
      _ -> body
    end
  end

  def process_request_headers(headers) do
    auth = Application.get_env(:changelog, :github_api_token)

    [{"Accept", "application/vnd.github.v3+json"},
     {"Authorization", "token #{auth}"} | headers]
  end

  def get_user_repos(username), do: get("/users/#{username}/repos")

  def create_file(source, content, message) do
    params = %{"content" => Base.encode64(content), "message" => message}

    source
    |> file_content_path
    |> put(Poison.encode!(params))
  end

  def edit_file(source, content, message) do
    {:ok, response} = get_file(source)

    encoded_content = Base.encode64(content)
    response_content = String.replace(response.body["content"], "\n", "")

    if encoded_content == response_content do
      {:ok, %{status_code: 200}}
    else
      params = %{
        "content" => encoded_content,
        "message" => message,
        "sha" => response.body["sha"]
      }

      source
      |> file_content_path
      |> put(Poison.encode!(params))
    end
  end

  def get_file(source), do: source |> file_content_path |> get

  def file_exists?(source) do
    {:ok, response} = get_file(source)
    response.status_code == 200
  end

  defp file_content_path(source) do
    "/repos/#{source.org}/#{source.repo}/contents/#{source.path}"
  end
end
