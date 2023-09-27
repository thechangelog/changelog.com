defmodule Changelog.Typesense.Client do
  use HTTPoison.Base

  def process_url(url), do: "#{Application.get_env(:changelog, :typesense_url)}/#{url}"

  def try_json_decode(body) do
    try do
      Jason.decode!(body)
    rescue
      _ -> body
    end
  end

  def process_request_headers(headers) do
    api_key = Application.get_env(:changelog, :typesense_api_key)

    [{"Accept", "application/json"}, {"x-typesense-api-key", api_key} | headers]
  end

  def create_collection(schema) do
    url = collections_path()

    case post!(url, Jason.encode!(schema)) do
      %{status_code: 200, body: body} ->
        {:ok, try_json_decode(body)}
      response ->
        response
    end
  end

  def upsert_documents(collection_name, documents) do
    url = "#{documents_path(collection_name)}/import"
    query_params = %{action: "upsert"}
    body = Enum.map_join(documents, "\n", fn d -> Jason.encode!(d) end)

    post(url, body, [], params: query_params, timeout: 30 * 60 * 1000, recv_timeout: 30 * 60 * 1000 )
  end

  def delete_document(collection_name, document_id) do
    url = "#{document_path(collection_name, document_id)}"

    case delete!(url) do
      %{status_code: 200, body: body} ->
        {:ok, try_json_decode(body)}
      response ->
        {:error, response}
    end
  end

  def search(collection_name, search_parameters) do
    url = "#{documents_path(collection_name)}/search"

    case get!(url, [], params: search_parameters) do
      %{status_code: 200, body: body} ->
        {:ok, try_json_decode(body)}
      response ->
        response
    end
  end

  defp collections_path do
    "/collections"
  end

  defp collection_path(name) do
    "/#{collections_path()}/#{name}"
  end

  defp documents_path(collection_name) do
    "#{collection_path(collection_name)}/documents"
  end

  defp document_path(collection_name, document_id) do
    "#{documents_path(collection_name)}/#{document_id}"
  end
end
