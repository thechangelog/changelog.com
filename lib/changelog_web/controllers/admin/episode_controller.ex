defmodule ChangelogWeb.Admin.EpisodeController do
  use ChangelogWeb, :controller

  alias Changelog.{Cache, Episode, EpisodeNewsItem, EpisodeTopic, EpisodeGuest,
                   EpisodeHost, EpisodeRequest, EpisodeStat, Github, NewsItem,
                   NewsQueue, Podcast}

  plug :assign_podcast
  plug Authorize, [Policies.Episode, :podcast]
  plug :scrub_params, "episode" when action in [:create, :update]

  # pass assigned podcast as a function arg
  def action(conn, _) do
    arg_list = [conn, conn.params, conn.assigns.podcast]
    apply(__MODULE__, action_name(conn), arg_list)
  end

  def index(conn, params, podcast) do
    filter = Map.get(params, "filter", "all")
    episodes = assoc(podcast, :episodes)

    page =
      case filter do
        "full"    -> Episode.full(episodes)
        "bonus"   -> Episode.bonus(episodes)
        "trailer" -> Episode.trailer(episodes)
        _else     -> episodes
      end
      |> Episode.published()
      |> Episode.newest_first()
      |> Repo.paginate(Map.put(params, :page_size, 50))

    episode_requests =
      podcast
      |> assoc(:episode_requests)
      |> EpisodeRequest.submitted()
      |> EpisodeRequest.newest_first()
      |> EpisodeRequest.preload_all()
      |> Repo.all()

    scheduled =
      episodes
      |> Episode.scheduled()
      |> Episode.newest_first()
      |> Repo.all()

    drafts =
      episodes
      |> Episode.unpublished()
      |> Episode.newest_first(:recorded_at)
      |> Repo.all()

    launch =
      page.entries
      |> Enum.filter(fn(ep) ->
        ep.type == :full &&
        Timex.compare(ep.published_at, Timex.shift(Timex.today(), days: -7)) == -1
      end)
      |> Enum.reverse()
      |> Enum.map(fn(ep) ->
        start_date = Timex.to_date(ep.published_at)
        end_date = Timex.shift(start_date, days: 7)

        reach =
          ep
          |> assoc(:episode_stats)
          |> EpisodeStat.between(start_date, end_date)
          |> EpisodeStat.sum_reach()
          |> Repo.one()
          |> Kernel.||(0)

        {ep.slug, reach}
      end)
      |> Enum.reject(fn({_, reach}) -> reach == 0 end)

    conn
    |> assign(:episodes, page.entries)
    |> assign(:episode_requests, episode_requests)
    |> assign(:scheduled, scheduled)
    |> assign(:drafts, drafts)
    |> assign(:filter, filter)
    |> assign(:page, page)
    |> assign(:reach, reach(podcast))
    |> assign(:launch, launch)
    |> render(:index)
  end

  def show(conn, %{"id" => slug}, podcast) do
    episode =
      podcast
      |> assoc(:episodes)
      |> Repo.get_by!(slug: slug)
      |> Episode.preload_all()

    news_item =
      NewsItem
      |> NewsItem.published()
      |> NewsItem.with_episode(episode)
      |> Repo.one()

    stats =
      episode
      |> assoc(:episode_stats)
      |> EpisodeStat.newest_first()
      |> Repo.all()

    conn
    |> assign(:episode, episode)
    |> assign(:item, news_item)
    |> assign(:stats, stats)
    |> render(:show)
  end

  def new(conn, _params, podcast) do
    podcast =
      podcast
      |> Podcast.preload_topics()
      |> Podcast.preload_hosts()

    default_hosts =
      podcast.hosts
      |> Enum.with_index(1)
      |> Enum.map(&EpisodeHost.build_and_preload/1)

    default_topics =
      podcast.topics
      |> Enum.with_index(1)
      |> Enum.map(&EpisodeTopic.build_and_preload/1)

    default_slug = Podcast.last_numbered_slug(podcast) + 1

    changeset =
      podcast
      |> build_assoc(:episodes,
        episode_topics: default_topics,
        episode_hosts: default_hosts,
        recorded_live: podcast.recorded_live,
        slug: default_slug)
      |> Episode.admin_changeset()

    render(conn, :new, changeset: changeset)
  end

  def create(conn, params = %{"episode" => episode_params}, podcast) do
    changeset =
      build_assoc(podcast, :episodes)
      |> Episode.preload_all()
      |> Episode.admin_changeset(episode_params)

    case Repo.insert(changeset) do
      {:ok, episode} ->
        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, admin_podcast_episode_path(conn, :edit, podcast.slug, episode.slug))
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:new, changeset: changeset)
    end
  end

  def edit(conn, %{"id" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Repo.get_by!(slug: slug)
      |> Episode.preload_all()

    changeset = Episode.admin_changeset(episode)
    render(conn, :edit, episode: episode, changeset: changeset)
  end

  def update(conn, params = %{"id" => slug, "episode" => episode_params}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Repo.get_by!(slug: slug)
      |> Episode.preload_all()

    changeset = Episode.admin_changeset(episode, episode_params)

    case Repo.update(changeset) do
      {:ok, episode} ->
        handle_notes_push_to_github(episode)
        EpisodeNewsItem.update(episode)
        Cache.delete(episode)
        params = replace_next_edit_path(params, admin_podcast_episode_path(conn, :edit, podcast.slug, episode.slug))

        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, admin_podcast_episode_path(conn, :index, podcast.slug))
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:edit, episode: episode, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Episode.unpublished()
      |> Repo.get_by!(slug: slug)

    Repo.delete!(episode)
    EpisodeNewsItem.delete(episode)
    Cache.delete(episode)

    conn
    |> put_flash(:result, "success")
    |> redirect(to: admin_podcast_episode_path(conn, :index, podcast.slug))
  end

  def publish(conn, params = %{"id" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Repo.get_by!(slug: slug)

    changeset = Ecto.Changeset.change(episode, %{published: true})

    case Repo.update(changeset) do
      {:ok, episode} ->
        handle_guest_thanks(params, episode)
        handle_news_item(conn, episode)
        handle_notes_push_to_github(episode)
        Cache.delete(episode)

        conn
        |> put_flash(:result, "success")
        |> redirect(to: admin_podcast_episode_path(conn, :index, podcast.slug))
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:edit, episode: episode, changeset: changeset)
    end
  end

  def unpublish(conn, %{"id" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Repo.get_by!(slug: slug)

    changeset = Ecto.Changeset.change(episode, %{published: false})

    case Repo.update(changeset) do
      {:ok, episode} ->
        Cache.delete(episode)

        conn
        |> put_flash(:result, "success")
        |> redirect(to: admin_podcast_episode_path(conn, :index, podcast.slug))
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:edit, episode: episode, changeset: changeset)
    end
  end

  def transcript(conn, %{"id" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Repo.get_by!(slug: slug)

    Github.Puller.update("transcripts", episode)

    conn
    |> put_flash(:result, "success")
    |> redirect(to: admin_podcast_episode_path(conn, :index, podcast.slug))
  end

  defp assign_podcast(conn = %{params: %{"podcast_id" => slug}}, _) do
    podcast = Repo.get_by!(Podcast, slug: slug) |> Podcast.preload_hosts
    assign(conn, :podcast, podcast)
  end

  defp handle_news_item(conn = %{params: %{"news" => _}}, episode) do
    episode
    |> EpisodeNewsItem.insert(conn.assigns.current_user)
    |> NewsQueue.append()
  end
  defp handle_news_item(_, _), do: false

  defp handle_notes_push_to_github(episode) do
    if Episode.is_published(episode) do
      episode = Episode.preload_podcast(episode)
      source = Github.Source.new("show-notes", episode)
      Github.Pusher.push(source, episode.notes)
    end
  end

  defp handle_guest_thanks(%{"thanks" => _}, episode), do: set_guest_thanks(episode, true)
  defp handle_guest_thanks(_, episode), do: set_guest_thanks(episode, false)

  defp reach(podcast) do
    now = Timex.today() |> Timex.shift(days: -1)
    then = now |> Timex.shift(years: -1)

    Cache.get_or_store("stats-reach-#{podcast.slug}-#{now}", fn ->
      %{as_of: Timex.now(),
        now_7:   EpisodeStat.date_range_reach(podcast, now, days: -7),
        now_30:  EpisodeStat.date_range_reach(podcast, now, days: -30),
        now_90:  EpisodeStat.date_range_reach(podcast, now, days: -90),
        prev_7:  EpisodeStat.date_range_reach(podcast, Timex.shift(now, days: -7), days: -7),
        prev_30: EpisodeStat.date_range_reach(podcast, Timex.shift(now, days: -30), days: -30),
        prev_90: EpisodeStat.date_range_reach(podcast, Timex.shift(now, days: -90), days: -90),
        then_7:  EpisodeStat.date_range_reach(podcast, then, days: -7),
        then_30: EpisodeStat.date_range_reach(podcast, then, days: -30),
        then_90: EpisodeStat.date_range_reach(podcast, then, days: -90)}
    end)
  end

  defp set_guest_thanks(episode, should_thank) do
    episode = Episode.preload_guests(episode)

    for guest <- episode.episode_guests do
      guest
      |> EpisodeGuest.changeset(%{thanks: should_thank})
      |> Repo.update()
    end
  end
end
