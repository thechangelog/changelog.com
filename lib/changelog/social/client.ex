defmodule Changelog.Social.Client do
  use HTTPoison.Base

  def base_url, do: "https://changelog.social"

  def process_url(url), do: base_url() <> "/api/v1#{url}"

  def process_response_body(body) do
    try do
      Jason.decode!(body)
    rescue
      _ -> body
    end
  end

  # shortcut to get authorization code url to be opened in browser context
  def authorize_url do
    params =
      [
        {"client_id", Application.get_env(:changelog, :mastodon_client_id)},
        {"scope", "read+write+follow"},
        {"redirect_uri", "urn:ietf:wg:oauth:2.0:oob"},
        {"response_type", "code"}
      ]
      |> Enum.map(fn {k, v} -> "#{k}=#{v}" end)
      |> Enum.join("&")

    base_url() <> "/oauth/authorize?" <> params
  end

  def default_token do
    Application.get_env(:changelog, :mastodon_api_token)
  end

  # once we have the one-time authorize code, use here for multi-use token
  def get_oauth_token(code) do
    body =
      {:form,
       [
         {"client_id", Application.get_env(:changelog, :mastodon_client_id)},
         {"client_secret", Application.get_env(:changelog, :mastodon_client_secret)},
         {"redirect_uri", "urn:ietf:wg:oauth:2.0:oob"},
         {"grant_type", "authorization_code"},
         {"code", code},
         {"scope", "read write follow"}
       ]}

    case HTTPoison.post(base_url() <> "/oauth/token", body) do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, body |> Jason.decode!() |> Map.get("access_token")}

      {:ok, %{body: body}} ->
        {:error, Jason.decode!(body)}
    end
  end

  # https://docs.joinmastodon.org/methods/statuses/#create
  def create_status(token, contents) do
    params = [
      {"status", contents}
    ]

    post("/statuses", {:form, params}, [{"authorization", "Bearer #{token}"}])
  end

  def get_status(id) do
    get("/statuses/#{id}", [{"authorization", "Bearer #{default_token()}"}])
  end
end
