defmodule Changelog.Notion do
	use HTTPoison.Base

	require Logger

	def process_url(url), do: "https://api.notion.com/v1#{url}"

	def process_response_body(body) do
	  try do
	    Jason.decode!(body)
	  rescue
	    _ -> body
	  end
	end

	def process_request_headers(headers) do
	  auth = Application.get_env(:changelog, :notion_api_token)

	  [{"Content-Type", "application/json"},
	   {"Authorization", "Bearer #{auth}"},
	   {"Notion-Version", "2022-02-22"} | headers]
	end

	def get_database(id), do: get("/databases/#{id}")

	def get_shipped_sponsorships(id, cursor \\ nil, accumulated \\ []) do
		params = %{
			filter: %{
				and: [%{property: "URL", rich_text: %{is_not_empty: true}}]
			}
		}

		params = if cursor, do: Map.merge(params, %{start_cursor: cursor}), else: params

		case post("/databases/#{id}/query", Jason.encode!(params)) do
			{:ok, %{body: %{"has_more" => true, "next_cursor" => next, "results" => sponsorships}}} ->
				get_shipped_sponsorships(id, next, accumulated ++ sponsorships)
			{:ok, %{body: %{"results" => sponsorships}}} ->
				accumulated ++ sponsorships
			{:ok, %{status_code: 400, body: %{"message" => message}}} ->
				Logger.warn("Notion: #{message}")
				[]
		end
	end

	def update_page(id, properties) do
		params = %{
			properties: properties
		}

		patch("/pages/#{id}", Jason.encode!(params))
	end
end
