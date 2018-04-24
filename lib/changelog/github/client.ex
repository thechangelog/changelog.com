defmodule Changelog.Github.Client do
  use HTTPoison.Base

  def process_url(url) do
    "https://api.github.com" <> url
  end

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

  def get_user_repos(username) do
    get("/users/#{username}/repos")
  end

  def create_file(source, content, message) do
    params = %{"content" => Base.encode64(content), "message" => message}
    put("/repos/#{source.org}/#{source.repo}/contents/#{source.path}", Poison.encode!(params))
  end

  def edit_file(source, content, message) do
    {:ok, response} = get_file(source)

    params = %{
      "content" => Base.encode64(content),
      "message" => message,
      "sha" => response.body["sha"]
    }

    put("/repos/#{source.org}/#{source.repo}/contents/#{source.path}", Poison.encode!(params))
  end

  def get_file(source) do
    get("/repos/#{source.org}/#{source.repo}/contents/#{source.path}")
  end

  def file_exists?(source) do
    {:ok, response} = get_file(source)
    response.status_code == 200
  end
end
