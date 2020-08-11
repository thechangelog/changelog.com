defmodule Changelog.Metacasts.Filterer.Cache do
    use GenServer

    alias Changelog.Metacasts.Filterer

    def start_link do
        GenServer.start_link(__MODULE__, nil, name: __MODULE__)
    end

    def compile(filter_string) do
        case Filterer.compile(filter_string) do
            {:ok, stream_filter} -> 
                :ok = GenServer.call(__MODULE__, {:set, filter_string, stream_filter})
                {:ok, stream_filter}
            error -> error
        end
    end

    def filter!(items, filter_string) do
        case get_or_compile(filter_string) do
            {:ok, stream_filter} -> Filterer.filter!(items, stream_filter)
            error -> raise Filterer.FiltererError, {:result_error, error}
        end
    end

    def filter(items, filter_string) do
        case get_or_compile(filter_string) do
            {:ok, stream_filter} -> Filterer.filter(items, stream_filter)
            error -> error
        end
    end

    def stat do
        GenServer.call(__MODULE__, :stat)
    end

    def clear do
        GenServer.cast(__MODULE__, :clear)
    end

    defp get_or_compile(filter_string) do
        case GenServer.call(__MODULE__, {:get, filter_string}) do
            :not_found -> compile(filter_string)
            {:ok, stream_filter} -> {:ok, stream_filter}
            error -> error
        end
    end

    @impl true
    def init(_) do
        {:ok, %{}}
    end

    @impl true
    def handle_call(:stat, _from, cache) do
        {:reply, cache, cache}
    end

    @impl true
    def handle_call({:set, filter_string, stream_filter}, _from, cache) do
        cache = Map.put(cache, filter_string, stream_filter)
        {:reply, :ok, cache}
    end

    @impl true
    def handle_call({:get, filter_string}, _from, cache) do
        result = case Map.get(cache, filter_string, nil) do
            nil -> :not_found
            stream_filter -> {:ok, stream_filter}
        end
        {:reply, result, cache}
    end

    @impl true
    def handle_cast(:clear, _cache) do
        {:noreply, %{}}
    end
end