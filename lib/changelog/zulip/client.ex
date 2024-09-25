defmodule Changelog.Zulip.Client do
  use HTTPoison.Base

  def process_url(url), do: "https://changelog.zulipchat.com/api/v1#{url}"

  def process_response_body(body) do
    try do
      Jason.decode!(body)
    rescue
      _ -> body
    end
  end

  def process_request_headers(headers) do
    username = Application.get_env(:changelog, :zulip_user)
    password = Application.get_env(:changelog, :zulip_api_key)
    auth = Base.encode64("#{username}:#{password}")
    [
      {"authorization", "Basic #{auth}"},
      {"content-type", "application/x-www-form-urlencoded"} | headers]
  end

  def handle({:ok, %{status_code: 200, body: body}}), do: body
  def handle({:ok, %{status_code: 400, body: body}}), do: handle({:error, %{reason: body["msg"]}})
  def handle({:error, %{reason: reason}}), do: %{"ok" => false, "error" => "#{reason}"}

  def get_message(message_id) do
    "/messages/#{message_id}"
    |> get()
    |> handle()
  end

  def post_message(channel, topic, content) do
    channel = URI.encode_www_form(channel)
    topic = URI.encode_www_form(topic)
    text = URI.encode_www_form(content)

    "/messages"
    |> post(~s(type=stream&to=#{channel}&topic=#{topic}&content=#{text}))
    |> handle()
  end
end
