defmodule Changelog.Zulip.Client do
  use HTTPoison.Base

  def process_url(url), do: Application.get_env(:changelog, :zulip_url) <> "/api/v1#{url}"

  def process_response_body(body) do
    try do
      Jason.decode!(body)
    rescue
      _ -> body
    end
  end

  def process_request_headers(headers) do
    [{"content-type", "application/x-www-form-urlencoded"} | headers]
  end

  def handle({:ok, %{status_code: 200, body: body}}), do: Map.merge(%{"ok" => true}, body)

  def handle({:ok, %{status_code: status, body: body}}) when status >= 400,
    do: handle({:error, %{reason: body["msg"]}})

  def handle({:error, %{reason: reason}}), do: %{"ok" => false, "msg" => "#{reason}"}

  def get_message(message_id) do
    headers = with_bot_headers()

    "/messages/#{message_id}"
    |> get(headers)
    |> handle()
  end

  def get_user(email) do
    headers = with_bot_headers()

    "/users/#{email}"
    |> get(headers)
    |> handle()
  end

  def get_users do
    headers = with_bot_headers()

    "/users"
    |> get(headers)
    |> handle()
  end

  def post_invite(email) do
    params = ~s(invitee_emails=#{email}&stream_ids=[]&include_realm_default_subscriptions=true)
    headers = with_admin_headers()

    "/invites"
    |> post(params, headers)
    |> handle()
  end

  def post_message(channel, topic, content) do
    channel = URI.encode_www_form(channel)
    topic = URI.encode_www_form(topic)
    text = URI.encode_www_form(content)

    params = ~s(type=stream&to=#{channel}&topic=#{topic}&content=#{text})
    headers = with_bot_headers()

    "/messages"
    |> post(params, headers)
    |> handle()
  end

  defp with_admin_headers(additional_headers \\ []) do
    username = Application.get_env(:changelog, :zulip_admin_user)
    password = Application.get_env(:changelog, :zulip_admin_api_key)
    auth = Base.encode64("#{username}:#{password}")

    [{"authorization", "Basic #{auth}"} | additional_headers]
  end

  defp with_bot_headers(additional_headers \\ []) do
    username = Application.get_env(:changelog, :zulip_bot_user)
    password = Application.get_env(:changelog, :zulip_bot_api_key)
    auth = Base.encode64("#{username}:#{password}")

    [{"authorization", "Basic #{auth}"} | additional_headers]
  end
end
