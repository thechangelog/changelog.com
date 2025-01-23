defmodule ChangelogWeb.Admin.EpisodeController do
  use ChangelogWeb, :controller

  alias Changelog.{
    Cache,
    Episode,
    EpisodeNewsItem,
    EpisodeTopic,
    EpisodeGuest,
    EpisodeHost,
    EpisodeRequest,
    EpisodeStat,
    Github,
    ListKit,
    NewsItem,
    NewsQueue,
    Podcast,
    Snap
  }

  alias Changelog.ObanWorkers.{AudioUpdater, FeedUpdater, NotesPusher}

  plug :assign_podcast
  plug Authorize, [Policies.Admin.Episode, :podcast]
  plug :scrub_params, "episode" when action in [:create, :update]

  # pass assigned podcast as a function arg
  def action(conn, _) do
    arg_list = [conn, conn.params, conn.assigns.podcast]
    apply(__MODULE__, action_name(conn), arg_list)
  end

  def index(conn, params, podcast) do
    filter = Map.get(params, "filter", "all")

    episodes =
      podcast
      |> assoc(:episodes)
      |> Episode.preload_episode_request()

    page =
      case filter do
        "full" -> Episode.full(episodes)
        "bonus" -> Episode.bonus(episodes)
        "trailer" -> Episode.trailer(episodes)
        _else -> episodes
      end
      |> Episode.published()
      |> Episode.newest_first()
      |> Repo.paginate(Map.put(params, :page_size, 50))

    episode_requests =
      podcast
      |> assoc(:episode_requests)
      |> EpisodeRequest.sans_episode()
      |> EpisodeRequest.fresh()
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
      |> Episode.newest_first(:published_at)
      |> Episode.newest_first(:recorded_at)
      |> Repo.all()

    conn
    |> assign_submitted(podcast)
    |> assign(:episodes, page.entries)
    |> assign(:episode_requests, episode_requests)
    |> assign(:scheduled, scheduled)
    |> assign(:drafts, drafts)
    |> assign(:filter, filter)
    |> assign(:page, page)
    |> assign(:downloads, downloads(podcast))
    |> render(:index)
  end

  defp assign_submitted(conn, podcast) do
    {submitted, news_episodes} =
      if Podcast.is_news(podcast) do
        {NewsItem.submitted()
         |> NewsItem.newest_first(:inserted_at)
         |> NewsItem.preload_all()
         |> Repo.all(),
         Episode.with_podcast_slug("news")
         |> Episode.newest_first(:recorded_at)
         |> Episode.limit(50)
         |> Repo.all()}
      else
        {[], []}
      end

    conn
    |> assign(:submitted, submitted)
    |> assign(:news_episodes, news_episodes)
  end

  def youtube(conn = %{method: "POST"}, %{"csv" => csv, "id" => id}, podcast) do
    episode = assoc(podcast, :episodes) |> Episode.preload_sponsors() |> Repo.get_by(id: id)
    chapters = Changelog.Kits.MarkerKit.to_youtube(csv)

    text =
      if episode do
        Phoenix.View.render_to_string(
          ChangelogWeb.Admin.EpisodeView,
          "_yt_#{podcast.slug}.text",
          %{episode: episode, chapters: chapters}
        )
      else
        chapters
      end

    json(conn, %{output: String.trim(text)})
  end

  def youtube(conn, _params, podcast) do
    episodes =
      podcast
      |> assoc(:episodes)
      |> Episode.newest_first()
      |> Episode.limit(50)
      |> Repo.all()

    conn
    |> assign(:episodes, episodes)
    |> render(:youtube)
  end

  def performance(conn, %{"ids" => ids}, podcast) do
    stats =
      podcast
      |> assoc(:episodes)
      |> Episode.with_ids(ids)
      |> Episode.full()
      |> Episode.newest_first()
      |> Episode.published(Timex.shift(Timex.today(), days: -7))
      |> Repo.all()
      |> Enum.reverse()
      |> Enum.map(fn ep ->
        start_date = Timex.to_date(ep.published_at)
        end_date = Timex.shift(start_date, days: 7)

        downloads =
          ep
          |> assoc(:episode_stats)
          |> EpisodeStat.between(start_date, end_date)
          |> EpisodeStat.sum_downloads()
          |> Repo.one()
          |> Kernel.||(0)

        {ep.slug, round(downloads), ep.title, round(ep.download_count)}
      end)
      |> Enum.reject(fn {_, downloads, _, _} -> downloads == 0 end)

    conn
    |> assign(:stats, stats)
    |> render("performance.json")
  end

  def show(conn, %{"id" => slug}, podcast) do
    episode =
      podcast
      |> assoc(:episodes)
      |> Repo.get_by!(slug: slug)
      |> Episode.preload_all()
      |> Episode.update_email_stats()

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

  def new(conn, params, podcast) do
    podcast =
      podcast
      |> Podcast.preload_topics()
      |> Podcast.preload_active_hosts()

    default_hosts =
      podcast.active_hosts
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
        request_id: params["request_id"],
        slug: default_slug
      )
      |> Episode.admin_changeset()

    conn
    |> assign(:changeset, changeset)
    |> assign(:episode_requests, episode_requests(podcast))
    |> render(:new)
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
        |> redirect_next(
          params,
          ~p"/admin/podcasts/#{podcast.slug}/episodes/#{episode.slug}/edit"
        )

      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> assign(:changeset, changeset)
        |> assign(:episode_requests, episode_requests(podcast))
        |> render(:new)
    end
  end

  def edit(conn, %{"id" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Repo.get_by!(slug: slug)
      |> Episode.preload_all()

    changeset = Episode.admin_changeset(episode)

    last_slug = Podcast.last_published_numbered_slug(podcast)

    conn
    |> assign(:episode, episode)
    |> assign(:changeset, changeset)
    |> assign(:last_slug, last_slug)
    |> assign(:episode_requests, episode_requests(episode))
    |> render(:edit)
  end

  def update(conn, params = %{"id" => slug, "episode" => episode_params}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Repo.get_by!(slug: slug)
      |> Episode.preload_all()

    changeset =
      Episode.admin_changeset(episode, Map.merge(episode_params, %{"episode_request" => %{}}))

    case Repo.update(changeset) do
      {:ok, episode} ->
        handle_notes_push_to_github(episode)
        EpisodeNewsItem.update(episode)
        handle_feed_updates(episode)
        Cache.delete(episode)
        Snap.purge(episode)

        unless any_files_uploaded?(changeset) do
          AudioUpdater.queue(episode)
        end

        params =
          replace_next_edit_path(
            params,
            ~p"/admin/podcasts/#{podcast.slug}/episodes/#{episode.slug}/edit"
          )

        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, ~p"/admin/podcasts/#{podcast.slug}/episodes")

      {:error, changeset} ->
        last_slug = Podcast.last_published_numbered_slug(podcast)

        conn
        |> put_flash(:result, "failure")
        |> assign(:episode, episode)
        |> assign(:last_slug, last_slug)
        |> assign(:changeset, changeset)
        |> assign(:episode_requests, episode_requests(episode))
        |> render(:edit)
    end
  end

  defp any_files_uploaded?(%{changes: changes}) do
    ListKit.overlap?(Map.keys(changes), ~w(audio_file plusplus_file)a)
  end

  def delete(conn, %{"id" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Episode.unpublished()
      |> Repo.get_by!(slug: slug)

    Repo.delete!(episode)
    EpisodeNewsItem.delete(episode)
    handle_feed_updates(episode)
    Cache.delete(episode)

    conn
    |> put_flash(:result, "success")
    |> redirect(to: ~p"/admin/podcasts/#{podcast.slug}/episodes")
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

        conn
        |> put_flash(:result, "success")
        |> redirect(to: ~p"/admin/podcasts/#{podcast.slug}/episodes")

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
        handle_feed_updates(episode)
        Cache.delete(episode)

        conn
        |> put_flash(:result, "success")
        |> redirect(to: ~p"/admin/podcasts/#{podcast.slug}/episodes")

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
    |> redirect(to: ~p"/admin/podcasts/#{podcast.slug}/episodes")
  end

  defp assign_podcast(conn = %{params: %{"podcast_id" => slug}}, _) do
    podcast = Repo.get_by!(Podcast, slug: slug) |> Podcast.preload_active_hosts()
    assign(conn, :podcast, podcast)
  end

  defp episode_requests(episode = %Episode{}) do
    episode
    |> Episode.preload_episode_request()
    |> Map.get(:episode_request)
    |> EpisodeRequest.preload_submitter()
    |> List.wrap()
    |> Kernel.++(episode_requests(episode.podcast))
  end

  defp episode_requests(podcast) do
    podcast
    |> assoc(:episode_requests)
    |> EpisodeRequest.active()
    |> EpisodeRequest.sans_episode()
    |> EpisodeRequest.newest_first()
    |> EpisodeRequest.preload_submitter()
    |> Repo.all()
  end

  # if the "news" param exists, it's a regular news item.
  defp handle_news_item(conn = %{params: %{"news" => _}}, episode) do
    logger = conn.assigns.current_user

    episode
    |> EpisodeNewsItem.insert(logger)
    |> NewsQueue.append()
  end

  # Otherwise we want a feed-only news item
  defp handle_news_item(conn, episode) do
    logger = conn.assigns.current_user

    episode
    |> EpisodeNewsItem.insert(logger, true)
    |> NewsQueue.append()
  end

  defp handle_notes_push_to_github(episode) do
    if Episode.is_published(episode) do
      NotesPusher.queue(episode)
    end
  end

  defp handle_feed_updates(episode) do
    if Episode.is_published(episode) do
      FeedUpdater.queue(episode)
    end
  end

  defp handle_guest_thanks(%{"thanks" => _}, episode), do: set_guest_thanks(episode, true)
  defp handle_guest_thanks(_, episode), do: set_guest_thanks(episode, false)

  defp downloads(podcast) do
    now = Timex.today() |> Timex.shift(days: -1)

    Cache.get_or_store("stats-downloads-#{podcast.slug}-#{now}", fn ->
      %{
        as_of: Timex.now(),
        now_7: EpisodeStat.date_range_downloads(podcast, :now_7),
        now_30: EpisodeStat.date_range_downloads(podcast, :now_30),
        now_90: EpisodeStat.date_range_downloads(podcast, :now_90),
        now_year: EpisodeStat.date_range_downloads(podcast, :now_year),
        prev_7: EpisodeStat.date_range_downloads(podcast, :prev_7),
        prev_30: EpisodeStat.date_range_downloads(podcast, :prev_30),
        prev_90: EpisodeStat.date_range_downloads(podcast, :prev_90),
        prev_year: EpisodeStat.date_range_downloads(podcast, :prev_year),
        then_7: EpisodeStat.date_range_downloads(podcast, :then_7),
        then_30: EpisodeStat.date_range_downloads(podcast, :then_30),
        then_90: EpisodeStat.date_range_downloads(podcast, :then_90)
      }
    end)
  end

  defp set_guest_thanks(episode, true), do: set_guest_thanks(episode, &EpisodeGuest.thanks/1)
  defp set_guest_thanks(episode, false), do: set_guest_thanks(episode, &EpisodeGuest.no_thanks/1)

  defp set_guest_thanks(episode, set_fn) when is_function(set_fn) do
    episode
    |> Episode.preload_guests()
    |> Map.get(:episode_guests)
    |> Enum.each(set_fn)
  end
end
