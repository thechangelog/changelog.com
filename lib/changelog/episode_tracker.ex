defmodule Changelog.EpisodeTracker do
  use GenServer

  alias Changelog.{Episode, NewsItem}
  alias Changelog.Metacasts.Filterer.Cache

  # 3 hour reset, to make sure this doesn't end up out of sync accidentally
  @reset_period_timeout 3 * 60 * 60 * 1000

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def list do
    GenServer.call(__MODULE__, :list)
  end

  # This is advantageous to avoid passing a copy of a thousand episode list
  # across the process boundary, it filters on the GenServer side
  def filter(filter_string) do
    GenServer.call(__MODULE__, {:filter, filter_string})
  end

  # Allow further stripping out of information my running an Enum.map with
  # the passed callback before crossing the process boundary
  def filter(filter_string, map_callback) do
    GenServer.call(__MODULE__, {:filter, filter_string, map_callback})
  end

  def get_episodes_as_ids(filter_string) do
    filter(filter_string, fn episode -> episode.id end)
  end

  def refresh do
    GenServer.cast(__MODULE__, :refresh)
  end

  def track(%{type: type, object_id: _object_id} = item) do
    if type == :audio do
      %{object: episode} = NewsItem.load_object(item)
      track(episode)
    end
  end

  def track(episode) do
    if Episode.is_public(episode) do
      GenServer.cast(__MODULE__, {:track, episode})
    end
  end

  def untrack(episode_id) do
    GenServer.cast(__MODULE__, {:untrack, episode_id})
  end

  @impl true
  def init(_) do
    episodes = refresh_episodes()
    schedule_reset()
    {:ok, episodes}
  end

  @impl true
  def handle_call(_, _, [] = episodes) do
    {:reply, {:error, :no_episodes}, episodes}
  end

  @impl true
  def handle_call(:list, _from, episodes) do
    {:reply, {:ok, episodes}, episodes}
  end

  @impl true
  def handle_call({:filter, filter_string}, _from, episodes) do
    filtered =
      case Cache.filter(episodes, filter_string) do
        {:ok, episode_stream} -> {:ok, Enum.to_list(episode_stream)}
        error -> error
      end

    {:reply, filtered, episodes}
  end

  @impl true
  def handle_call({:filter, filter_string, map_callback}, _from, episodes) do
    filtered =
      case Cache.filter(episodes, filter_string) do
        {:ok, episode_stream} -> {:ok, Enum.map(episode_stream, map_callback)}
        error -> error
      end

    {:reply, filtered, episodes}
  end

  @impl true
  def handle_cast(:refresh, _episodes) do
    episodes = refresh_episodes()
    {:noreply, episodes}
  end

  @impl true
  def handle_cast({:track, episode}, episodes) do
    %{id: id} = flat = Episode.flatten_episode_for_filtering(episode)
    # Remove episode if already in episode list
    episodes = untrack(episodes, id)

    # Add the flattened episode, episode tracked
    {:noreply, [flat | episodes]}
  end

  @impl true
  def handle_cast({:untrack, episode_id}, episodes) do
    episodes = untrack(episodes, episode_id)
    {:noreply, episodes}
  end

  @impl true
  def handle_info(:periodic_reset, episodes) do
    schedule_reset()
    handle_cast(:refresh, episodes)
  end

  defp untrack(episodes, id) do
    # Remove episode if already in episode list
    Enum.reject(episodes, fn episode ->
      episode.id == id
    end)
  end

  defp refresh_episodes do
    {:ok, episodes} = Episode.flatten_for_filtering()
    episodes
  end

  defp schedule_reset, do: Process.send_after(self(), :periodic_reset, @reset_period_timeout)
end
