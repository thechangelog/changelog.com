defmodule Changelog.Slack.Client do
  use HTTPoison.Base

  def process_url(url) do
    "https://changelog.slack.com/api/" <> url
  end

  def process_response_body(body) do
    try do
      Poison.decode!(body, keys: :atoms!)
    rescue
      _ -> body
    end
  end

  def process_request_headers(headers) do
    [{"content-type", "application/x-www-form-urlencoded"} | headers]
  end

  def invite(email) do
    token = Application.get_env(:changelog, :slack_api_token)
    form = ~s(email=#{email}&token=#{token}&resend=true)
    {_, response} = post("/users.admin.invite", form)
    response.body
  end
end
