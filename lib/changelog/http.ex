defmodule Changelog.HTTP do
  @moduledoc """
  This is a wrapper around HTTPoison that allows us to centralize certain global
  headers & options when making outbound HTTP requests
  """

  @options [ssl: [{:middlebox_comp_mode, false}]]

  def request(method, url, body \\ "", headers \\ [], options \\ []) do
    case HTTPoison.request(method, url, body, headers, options) do
      {:error, _} -> HTTPoison.request(method, url, body, headers, with_shared_options(options))
      response -> response
    end
  end

  def get(url, headers \\ [], options \\ []) do
    case HTTPoison.get(url, headers, options) do
      {:error, _} -> HTTPoison.get(url, headers, with_shared_options(options))
      response -> response
    end
  end

  def get!(url, headers \\ [], options \\ []) do
    try do
      HTTPoison.get!(url, headers, options)
    rescue
      _ -> HTTPoison.get!(url, headers, with_shared_options(options))
    end
  end

  def post(url, body, headers \\ [], options \\ []) do
    case HTTPoison.post(url, body, headers, options) do
      {:error, _} -> HTTPoison.post(url, body, headers, with_shared_options(options))
      response -> response
    end
  end

  def post!(url, body, headers \\ [], options \\ []) do
    try do
      HTTPoison.post!(url, body, headers, options)
    rescue
      _ -> HTTPoison.post!(url, body, headers, with_shared_options(options))
    end
  end

  defp with_shared_options(options), do: Keyword.merge(options, @options)
end
