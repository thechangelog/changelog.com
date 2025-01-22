defmodule ChangelogWeb.EpisodeController do
  use ChangelogWeb, :controller

  alias Changelog.{Episode, NewsItem, Podcast, Subscription}
  alias ChangelogWeb.{Email, EpisodeView, LiveView, TimeView, Xml}

  plug :assign_podcast

  def action(conn, _) do
    arg_list = [conn, conn.params, conn.assigns.podcast]
    apply(__MODULE__, action_name(conn), arg_list)
  end

  # Changelog News episodes are handled in NewsItemController
  def show(conn, %{"slug" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Episode.published()
      |> Episode.preload_all()
      |> Repo.get_by!(slug: slug)
      |> Episode.load_news_item()

    conn
    |> assign(:podcast, podcast)
    |> assign(:episode, episode)
    |> assign(:item, episode.news_item)
    |> render(:show)
  end

  def img(conn, params = %{"slug" => slug}, podcast = %{slug: "news"}) do
    episode =
      assoc(podcast, :episodes)
      |> Episode.preload_all()
      |> Repo.get_by!(slug: slug)

    shape = Map.get(params, "shape", "rectangle")

    conn
    |> assign(:episode, episode)
    |> assign(:shape, shape)
    |> render(:img_news, layout: false)
  end

  def img(conn, %{"slug" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Episode.preload_all()
      |> Repo.get_by!(slug: slug)

    conn
    |> assign(:episode, episode)
    |> render(:img, layout: false)
  end

  def embed(conn, params = %{"slug" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Episode.published()
      |> Episode.preload_all()
      |> Repo.get_by!(slug: slug)

    theme = Map.get(params, "theme", "night")
    source = Map.get(params, "source", "default")

    conn
    |> put_layout(false)
    |> assign(:podcast, podcast)
    |> assign(:episode, episode)
    |> assign(:theme, theme)
    |> assign(:source, source)
    |> render(:embed)
  end

  def preview(conn, %{"slug" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Episode.preload_all()
      |> Repo.get_by!(slug: slug)

    conn
    |> assign(:podcast, podcast)
    |> assign(:episode, episode)
    |> assign(:item, nil)
    |> render(:show)
  end

  def play(conn, %{"slug" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Episode.preload_podcast()
      |> Repo.get_by!(slug: slug)

    conn
    |> assign(:podcast, podcast)
    |> assign(:episode, episode)
    |> render("play.json")
  end

  def share(conn, %{"slug" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Episode.published()
      |> Episode.preload_podcast()
      |> Repo.get_by!(slug: slug)

    render(conn, "share.json", podcast: podcast, episode: episode)
  end

  def discuss(conn, %{"slug" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Episode.published()
      |> Episode.preload_podcast()
      |> Repo.get_by!(slug: slug)

    if item = Episode.get_news_item(episode) do
      redirect(conn, to: ~p"/news/#{NewsItem.slug(item)}")
    else
      redirect(conn, to: ~p"/#{podcast.slug}/#{episode.slug}")
    end
  end

  def transcript(conn, %{"slug" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Episode.published()
      |> Episode.with_transcript()
      |> Episode.preload_all()
      |> Repo.get_by!(slug: slug)

    conn
    |> assign(:podcast, podcast)
    |> assign(:episode, episode)
    |> render(:transcript, layout: false)
  end

  def chapters(conn, params = %{"slug" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Episode.published()
      |> Repo.get_by!(slug: slug)

    chapters =
      if Map.has_key?(params, "pp") do
        episode.plusplus_chapters
      else
        episode.audio_chapters
      end

    conn
    |> assign(:chapters, chapters)
    |> render("chapters.json")
  end

  def psc(conn, params = %{"slug" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Episode.published()
      |> Repo.get_by!(slug: slug)

    chapters =
      if Map.has_key?(params, "pp") do
        episode.plusplus_chapters
      else
        episode.audio_chapters
      end

    xml =
      chapters
      |> Xml.Chapters.document()
      |> Xml.generate()

    conn
    |> put_resp_header("access-control-allow-origin", "*")
    |> put_resp_content_type("application/xml")
    |> send_resp(200, xml)
  end

  def email(conn, %{"slug" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Episode.published()
      |> Episode.preload_all()
      |> Repo.get_by!(slug: slug)

    email = Email.episode_published(%{person: nil, context: ""}, episode)

    conn
    |> assign(:episode, episode)
    |> assign(:email, email)
    |> render(:email, layout: false)
  end

  def live(conn, %{"slug" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Episode.recorded_live()
      |> Episode.with_youtube_id()
      |> Repo.get_by!(slug: slug)

    redirect(conn, external: LiveView.live_url(episode))
  end

  def time(conn, %{"slug" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Episode.recorded_live_at_known_time()
      |> Repo.get_by!(slug: slug)

    redirect(conn, external: TimeView.time_is_url(episode.recorded_at))
  end

  def subscribe(
        conn = %{method: "POST", assigns: %{current_user: me}},
        %{"slug" => slug},
        podcast
      ) do
    episode =
      podcast
      |> assoc(:episodes)
      |> Episode.published()
      |> Repo.get_by!(slug: slug)

    context = "you clicked the link to be notified on changelog.com"
    Subscription.subscribe(me, episode, context)

    conn
    |> put_flash(:success, "We'll email you when the transcript is published 📥")
    |> redirect(to: ~p"/#{podcast.slug}/#{episode.slug}")
  end

  def unsubscribe(
        conn = %{method: "POST", assigns: %{current_user: me}},
        %{"slug" => slug},
        podcast
      ) do
    episode =
      podcast
      |> assoc(:episodes)
      |> Episode.published()
      |> Repo.get_by!(slug: slug)

    Subscription.unsubscribe(me, episode)

    conn
    |> put_flash(:success, "You're no longer subscribed. Resubscribe any time 🤗")
    |> redirect(to: ~p"/#{podcast.slug}/#{episode.slug}")
  end

  def yt(conn, %{"slug" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Episode.preload_podcast()
      |> Repo.get_by!(slug: slug)

    redirect(conn, external: EpisodeView.yt_url(episode))
  end

  defp assign_podcast(conn, _) do
    podcast = Repo.get_by!(Podcast, slug: conn.params["podcast"])
    assign(conn, :podcast, podcast)
  end
end
