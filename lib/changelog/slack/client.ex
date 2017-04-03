defmodule Changelog.Slack.Client do
  use HTTPoison.Base

  def process_url(url) do
    "https://changelog.slack.com/api/" <> url
  end

  def process_response_body(body) do
    try do
      Poison.decode!(body)
    rescue
      _ -> body
    end
  end

  def process_request_headers(headers) do
    [{"content-type", "application/x-www-form-urlencoded"} | headers]
  end

  def handle({:ok, %HTTPoison.Response{status_code: 200, body: body}}), do: body

  def invite(email) do
    token = Application.get_env(:changelog, :slack_api_token)
    form = ~s(email=#{email}&token=#{token}&resend=true)
    post("/users.admin.invite", form) |> handle
  end

  def list do
    token = Application.get_env(:changelog, :slack_api_token)
    get("/users.list?token=#{token}") |> handle
  end
end
