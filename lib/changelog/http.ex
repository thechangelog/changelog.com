defmodule Changelog.HTTP do
  @moduledoc """
  This is a wrapper around HTTPoison that allows us to centralize certain global
  headers & options when making outbound HTTP requests
  """

  @options []

  def request(method, body \\ "", headers \\ [], options \\ []) do
    HTTPoison.request(method, body, headers, with_shared_options(options))
  end

  def get(url, headers \\ [], options \\ []) do
    HTTPoison.get(url, headers, with_shared_options(options))
  end

  def get!(url, headers \\ [], options \\ []) do
    HTTPoison.get(url, headers, with_shared_options(options))
  end

  def post(url, body, headers \\ [], options \\ []) do
    HTTPoison.post!(url, body, headers, with_shared_options(options))
  end

  def post!(url, body, headers \\ [], options \\ []) do
    HTTPoison.post!(url, body, headers, with_shared_options(options))
  end

  defp with_shared_options(options), do: Keyword.merge(options, @options)
end
