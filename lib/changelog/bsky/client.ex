defmodule Changelog.Bsky.Client do
  use HTTPoison.Base

  def process_url(url), do: "https://bsky.social/xrpc/#{url}"

  def process_response_body(body) do
    try do
      Jason.decode!(body)
    rescue
      _ -> body
    end
  end

  def process_request_headers(headers) do
    [{"accept", "application/json"} | headers]
  end

  def create_session do
    params = %{
      "identifier" => Application.get_env(:changelog, :bsky_user),
      "password" => Application.get_env(:changelog, :bsky_pass)
    }

    case post("com.atproto.server.createSession", Jason.encode!(params), [
           {"content-type", "application/json"}
         ]) do
      {:ok, %{body: %{"accessJwt" => jwt}}} -> {:ok, jwt}
      {:error, error} -> {:error, error}
    end
  end

  def create_blob(data) do
    with {:ok, jwt} <- create_session() do
      case post("com.atproto.repo.uploadBlob", data, [
             {"content-type", "*/*"},
             {"authorization", "Bearer #{jwt}"}
           ]) do
        {:ok, %{body: %{"blob" => blob}}} -> {:ok, blob}
        {:error, error} -> {:error, error}
      end
    end
  end

  def create_post(text, link, title, description, img) do
    params =
      %{
        "repo" => Application.get_env(:changelog, :bsky_user),
        "collection" => "app.bsky.feed.post",
        "record" => %{
          "text" => text,
          "facets" => [
            %{
              "index" => get_link_index(text, link),
              "features" => get_link_features(text, link)
            }
          ],
          "embed" => %{
            "$type" => "app.bsky.embed.external",
            "external" => %{
              "uri" => "https://#{link}",
              "title" => title,
              "description" => description,
              "thumb" => img
            }
          },
          "createdAt" => Timex.now() |> DateTime.to_iso8601()
        }
      }

    with {:ok, jwt} <- create_session() do
      post("com.atproto.repo.createRecord", Jason.encode!(params), [
        {"content-type", "application/json"},
        {"authorization", "Bearer #{jwt}"}
      ])
    end
  end

  defp get_link_index(text, link) do
    [before, _after] = String.split(text, link)
    # must use `byte_size/1` instead of `length/1` because emoji
    start_index = byte_size(before)
    end_index = start_index + byte_size(link)
    %{"byteStart" => start_index, "byteEnd" => end_index}
  end

  defp get_link_features(_text, link) do
    [
      %{"$type" => "app.bsky.richtext.facet#link", "uri" => "https://" <> link}
    ]
  end
end
