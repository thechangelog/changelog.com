defmodule Changelog.Metacasts.Filterer do
  require Logger

  alias Changelog.Metacasts.Filterer.{FiltererError, Parser, Generator}

  @moduledoc """
  This module allows filtering of simple datasets with a useful small DSL built
  specifically to filter podcast episodes. Especially to make custom feeds, so
  called metacasts.

  iex> Changelog.Metacasts.Filterer.filter!([%{podcast: "changelog"}, %{podcast: "gotime"}], "only podcast: changelog")
  ...> |> Enum.to_list()
  [%{podcast: "changelog"}]

  iex> Changelog.Metacasts.Filterer.filter!([%{podcast: "changelog"}, %{podcast: "gotime"}], "except podcast: changelog")
  ...> |> Enum.to_list()
  [%{podcast: "gotime"}]
  """

  @statement_limit 256

  def compile(filter_string) do
    case Parser.parse(filter_string) do
      {:ok, representation} -> 
        if length(representation.statements) > @statement_limit do
          {:error, :too_many_statements}
        else
          {:ok, Generator.generate_stream_filters(representation)}
        end
      {:error, error} -> {:error, error}
      error -> error
    end
  end

  def filter!(items, filter_string) when is_binary(filter_string) do
    case filter(items, filter_string) do
      {:ok, result} -> result
      {:error, error} -> raise FiltererError, {:result_error, error}
      error -> raise FiltererError, {:result_error, error}
    end
  end

  def filter!(items, stream_filter) when is_function(stream_filter), do: stream_filter.(items)

  def filter(items, filter_string) when is_binary(filter_string) do
    case compile(filter_string) do
      {:ok, stream_filter} -> {:ok, stream_filter.(items)}
      {:error, error} -> {:error, error}
      error -> {:error, error}
    end
  end

  def filter(items, stream_filter) when is_function(stream_filter), do: {:ok, stream_filter.(items)}

  def statement_limit, do: @statement_limit
end
