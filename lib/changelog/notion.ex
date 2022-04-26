defmodule Changelog.Notion do
	use HTTPoison.Base

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

	def get_database(id) do
		get("/databases/#{id}")
	end

	def get_shipped_sponsorships(id) do
		params = %{
			filter: %{
				and: [%{property: "URL", rich_text: %{is_not_empty: true}}]
			}
		}

		post("/databases/#{id}/query", Jason.encode!(params))
	end

	def update_page(id, properties) do
		params = %{
			properties: properties
		}

		patch("/pages/#{id}", Jason.encode!(params))
	end
end
