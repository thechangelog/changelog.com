defmodule Changelog.Slack.Client do
  use HTTPoison.Base

  def process_url(url), do: "https://changelog.slack.com/api#{url}"

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

  def handle({:ok, %{status_code: 200, body: body}}), do: body
  def handle({:error, %{reason: reason}}), do: %{"ok" => false, "error" => "#{reason}"}

  def invite(email) do
    token = Application.get_env(:changelog, :slack_invite_api_token)
    form = ~s(email=#{email}&token=#{token}&resend=true)
    "/users.admin.invite" |> post(form) |> handle
  end

  def list do
    token = Application.get_env(:changelog, :slack_app_api_token)
    "/users.list?token=#{token}" |> get |> handle
  end

  def im(user, message) do
    if String.starts_with?(user, "@") do
      message(user, message)
    else
      %{"channel" => %{"id" => channel}} = open_im(user)
      message(channel, message)
    end
  end

  def message(channel, message) do
    token = Application.get_env(:changelog, :slack_app_api_token)
    form = ~s(token=#{token}&channel=#{channel}&as_user=true&text=#{message})
    "/chat.postMessage" |> post(form) |> handle
  end

  defp open_im(user_id) do
    token = Application.get_env(:changelog, :slack_app_api_token)
    form = ~s(token=#{token}&user=#{user_id})
    "/im.open" |> post(form) |> handle
  end
end
