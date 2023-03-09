defmodule Changelog.Cache2 do
  @moduledoc """
  This cache implementation is a basic way of keeping cached feeds in memory
  and working around the Changelog app not yet being clustered.

  The cache is updated and coordinated in a simplistic and naive way which
  should be sufficient as any missing cached item should be re-generated
  on request and any stale items should be replaced on the next update or
  when a listener complains.

  Nodes coming and going can easily place this out of phase but it should
  be within reason for the application's needs.

  We pass a message to all nodes when `clear_all/1` is called and similarly
  when `set_all/2` is called.

  This entire implementation would be straight-forward over Phoenix PubSub
  if we had Redis or clustering. Now we'll use Postgres LISTEN/NOTIFY instead.
  Fun!
  """
  use GenServer
  require Logger

  @table_name :thecache
  @postgres_notify_payload_limit 8000

  def start_link(args) do
    name = args[:name] || __MODULE__
    GenServer.start_link(__MODULE__, nil, name: name)
  end

  @impl true
  def init(nil) do
    if :ets.whereis(@table_name) == :undefined do
      :ets.new(@table_name, [:named_table, :public])
    end

    ref = subscribe()

    {:ok, %{ref: ref}}
  end

  defp subscribe do
    {:ok, listen_ref} =
      Postgrex.Notifications.listen(Changelog.PostgresNotifications, "cache_ops")

    listen_ref
  end

  def clear_all(key) do
    Ecto.Adapters.SQL.query(Changelog.Repo, "NOTIFY cache_ops, 'clear:#{key}'", [])
  end

  @doc """
  This function takes a key and an MFA which is a tuple of
  `{module, function, arguments}` which will be used to create
  a value on every node running the cache. We don't just send
  the data because it won't fit the NOTIFY/LISTEN mechanism
  and is rather large for passing around willy-nilly regardless.
  So each node gets to generate their own data. Your code is deterministic,
  right Jerod?
  """
  def set_all(key, {module, function, arguments}) do
    result = apply(module, function, arguments)
    set(key, result)

    item = term_to_postgres_string!({self(), key, module, function, arguments})
    Ecto.Adapters.SQL.query(Changelog.Repo, "NOTIFY cache_ops, 'set:#{item}'", [])
    result
  end

  def get(key) do
    result = :ets.lookup(@table_name, key)

    case result do
      [] -> nil
      [{_key, value}] -> value
    end
  end

  defp set(key, data) do
    :ets.insert(@table_name, {key, data})
  end

  defp clear(key) do
    :ets.delete(@table_name, key)
  end

  @impl true
  def handle_info(
        {:notification, _notification_pid, _listen_ref, "cache_ops", "clear:" <> key},
        state
      ) do
    Logger.debug(
      "Clearing cache key '#{key}' on node #{inspect(Node.self())}, process #{inspect(self())}"
    )

    clear(key)
    {:noreply, state}
  end

  @impl true
  def handle_info(
        {:notification, _notification_pid, _listen_ref, "cache_ops", "set:" <> item},
        state
      ) do
    {source, key, module, function, arguments} = postgres_string_to_term!(item)

    if source != self() do
      Logger.debug(
        "Setting cache key '#{key}' on node #{inspect(Node.self())}, process #{inspect(self())}"
      )

      data = apply(module, function, arguments)
      set(key, data)
    end

    {:noreply, state}
  end

  defp term_to_postgres_string!(term) do
    term
    # Transform erlang data into a serialized form that can be transmitted
    |> :erlang.term_to_binary()
    # Postgres only wants simple string literals so we transform our binary
    |> Base.encode64()
    |> tap(fn string ->
      # Just make it blow up if you for some reason send a hilariously big key
      # or MFA that violates what we'd expect Postgres to handle
      true = byte_size(string) < @postgres_notify_payload_limit
    end)
  end

  defp postgres_string_to_term!(string) do
    string
    |> Base.decode64!()
    |> :erlang.binary_to_term([:safe])
  end
end
