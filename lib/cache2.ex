defmodule Changelog.Cache2 do
  use GenServer

  @table_name :the_cache

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(nil) do
    :ets.new(@table_name, [:named_table, :public])
    ref = subscribe()

    {:ok, %{ref: ref}}
  end

  defp subscribe do
    # TODO: Can be replace with Phoenix.PubSub.subscribe later, or now
    {:ok, listen_ref} = Postgrex.Notifications.listen(Changelog.PostgresNotifications, "cache_clears")
    listen_ref
  end

  def clear_all(key) do
    # TODO: Can be replace with Phoenix.PubSub.broadcast later, or now
    Ecto.Adapters.SQL.query(Changelog.Repo, "NOTIFY cache_clears, '#{key}'", [])
  end

  def set(key, data) do
    :ets.insert(@table_name, {key, data})
  end

  def get(key) do
    result = :ets.lookup(@table_name, key)
    case result do
      [] -> nil
      [{_key, value}] -> value
    end
  end

  def clear(key) do
    :ets.delete(@table_name, key)
  end

  @impl true
  def handle_info({:notification, _notification_pid, _listen_ref, "cache_clears", key}, state) do
    IO.inspect(key, label: "clearing")
    clear(key)
    {:noreply, state}
  end
end
