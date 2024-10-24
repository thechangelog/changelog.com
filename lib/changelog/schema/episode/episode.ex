defmodule Changelog.Episode do
  use Changelog.Schema, default_sort: :published_at

  require Logger

  alias Changelog.{
    EpisodeChapter,
    EpisodeGuest,
    EpisodeHost,
    EpisodeRequest,
    EpisodeTopic,
    EpisodeStat,
    EpisodeSponsor,
    Files,
    Github,
    NewsItem,
    Notifier,
    Podcast,
    Regexp,
    TypesenseSearch,
    Transcripts
  }

  defenum(Type, full: 0, bonus: 1, trailer: 2)

  schema "episodes" do
    field :slug, :string
    field :guid, :string

    field :title, :string
    field :subtitle, :string
    field :type, Type

    field :featured, :boolean, default: false
    field :highlight, :string
    field :subhighlight, :string

    field :summary, :string
    field :notes, :string
    field :doc_url, :string
    field :socialize_url, :string

    field :published, :boolean, default: false
    field :published_at, :utc_datetime
    field :recorded_at, :utc_datetime
    field :recorded_live, :boolean, default: false
    field :youtube_id, :string

    field :cover, Files.Cover.Type

    field :audio_file, Files.Audio.Type
    field :audio_bytes, :integer
    field :audio_duration, :integer

    embeds_many :audio_chapters, EpisodeChapter, on_replace: :delete

    field :plusplus_file, Files.PlusPlus.Type
    field :plusplus_bytes, :integer
    field :plusplus_duration, :integer

    embeds_many :plusplus_chapters, EpisodeChapter, on_replace: :delete

    field :download_count, :float
    field :import_count, :float
    field :reach_count, :integer

    field :email_subject, :string
    field :email_teaser, :string
    field :email_content, :string
    field :email_sends, :integer
    field :email_opens, :integer

    field :transcript, {:array, :map}
    # has_transcript is only used to know whether or not the episode has a
    # transcript even though we're not `select`ing it to reduce query load times
    field :has_transcript, :boolean, virtual: true, default: false

    # this exists merely to satisfy the compiler
    # see load_news_item/1 and get_news_item/1 for actual use
    field :news_item, :map, virtual: true

    belongs_to :podcast, Podcast
    belongs_to :episode_request, EpisodeRequest, foreign_key: :request_id

    has_many :episode_hosts, EpisodeHost
    has_many :hosts, through: [:episode_hosts, :person]
    has_many :episode_guests, EpisodeGuest
    has_many :guests, through: [:episode_guests, :person]
    has_many :episode_topics, EpisodeTopic
    has_many :topics, through: [:episode_topics, :topic]
    has_many :episode_sponsors, EpisodeSponsor
    has_many :sponsors, through: [:episode_sponsors, :sponsor]
    has_many :episode_stats, EpisodeStat

    timestamps()
  end

  def distinct_podcast(query), do: from(q in query, distinct: q.podcast_id)
  def featured(query \\ __MODULE__), do: from(q in query, where: q.featured == true)

  def next_after(query \\ __MODULE__, episode),
    do: from(q in query, where: q.published_at > ^episode.published_at)

  def previous_to(query \\ __MODULE__, episode),
    do: from(q in query, where: q.published_at < ^episode.published_at)

  def published(query \\ __MODULE__), do: published(query, Timex.now())

  def published(query, as_of),
    do: from(q in query, where: q.published, where: q.published_at <= ^Timex.to_datetime(as_of))

  def recorded_between(query, start_time, end_time),
    do: from(q in query, where: q.recorded_at <= ^start_time, where: q.end_time < ^end_time)

  def recorded_future_to(query, time), do: from(q in query, where: q.recorded_at > ^time)

  def recorded_live(query \\ __MODULE__),
    do: from(q in query, where: q.recorded_live == true)

  def recorded_live_at_known_time(query \\ __MODULE__),
    do: from(q in query, where: q.recorded_live == true, where: not is_nil(q.recorded_at))

  def with_youtube_id(query \\ __MODULE__),
    do: from(q in query, where: not is_nil(q.youtube_id))

  def scheduled(query \\ __MODULE__),
    do: from(q in query, where: q.published, where: q.published_at > ^Timex.now())

  def search(query, term),
    do: from(q in query, where: fragment("search_vector @@ plainto_tsquery('english', ?)", ^term))

  def unpublished(query \\ __MODULE__), do: from(q in query, where: not q.published)

  def top_downloaded_first(query \\ __MODULE__),
    do: from(q in query, order_by: [desc: :download_count])

  def with_numbered_slug(query \\ __MODULE__),
    do: from(q in query, where: fragment("slug ~ E'^\\\\d+$'"))

  def with_slug(query \\ __MODULE__, slug), do: from(q in query, where: q.slug == ^slug)

  def with_slug_prefix(query \\ __MODULE__, prefix),
    do: from(q in query, where: like(q.slug, ^"#{prefix}%"))

  def with_podcast_slug(query \\ __MODULE__, slug)
  def with_podcast_slug(query, nil), do: query

  def with_podcast_slug(query, slug),
    do:
      from(q in query,
        join: p in Podcast,
        on: true,
        where: q.podcast_id == p.id,
        where: p.slug == ^slug
      )

  def with_transcript(query \\ __MODULE__),
    do: from(q in query, where: fragment("? != '{}'", q.transcript))

  def sans_transcript(query \\ __MODULE__),
    do: from(q in query, where: fragment("? = '{}'", q.transcript))

  def full(query \\ __MODULE__), do: from(q in query, where: q.type == ^:full)
  def bonus(query \\ __MODULE__), do: from(q in query, where: q.type == ^:bonus)
  def trailer(query \\ __MODULE__), do: from(q in query, where: q.type == ^:trailer)

  # Loading an episode's transcript adds significant query time. This function
  # allows us to opt out of loading the transcript when we aren't going to use
  # it. It also sets the `has_transcript` boolean field so that we know whether
  # or not the episode does, indeed, have a transcript even when it's not loaded.
  def exclude_transcript(query \\ __MODULE__) do
    fields = __MODULE__.__schema__(:fields) |> Enum.reject(&(&1 == :transcript))

    from(q in query,
      select: ^fields,
      select_merge: %{has_transcript: fragment("? != '{}'", q.transcript)}
    )
  end

  def has_transcript(%{has_transcript: true}), do: true
  def has_transcript(%{transcript: nil}), do: false
  def has_transcript(%{transcript: []}), do: false
  def has_transcript(_), do: true

  def is_public(episode, as_of \\ Timex.now()) do
    is_published(episode) && Timex.before?(episode.published_at, as_of)
  end

  def is_published(episode), do: episode.published

  def is_publishable(episode) do
    episode = preload_podcast(episode)

    validated =
      episode
      |> change(%{})
      |> validate_required([:slug, :title, :published_at, :summary, :audio_file])
      |> validate_format(:slug, Regexp.slug(), message: Regexp.slug_message())
      |> unique_constraint(:slug, name: :episodes_slug_podcast_id_index)
      |> cast_assoc(:episode_hosts)

    validated =
      if Podcast.is_news(episode.podcast) do
        validate_required(validated, [:email_subject, :email_teaser, :email_content])
      else
        validated
      end

    validated.valid? && !is_published(episode)
  end

  def admin_changeset(struct, attrs \\ %{}) do
    attrs = attrs_with_chapters_sorted_by_starts_at(attrs)

    struct
    |> cast(attrs, ~w(slug title subtitle published featured request_id highlight
      subhighlight summary notes doc_url socialize_url published_at recorded_at
      email_subject email_teaser email_content recorded_live youtube_id guid type)a)
    |> purge_audio_when_slug_changes()
    |> prep_audio_file(attrs)
    |> prep_plusplus_file(attrs)
    |> cast_attachments(attrs, [:audio_file, :plusplus_file, :cover])
    |> cast_embed(:audio_chapters)
    |> cast_embed(:plusplus_chapters)
    |> validate_required([:slug, :title, :published, :featured])
    |> validate_format(:slug, Regexp.slug(), message: Regexp.slug_message())
    |> validate_format(:doc_url, Regexp.http(), message: Regexp.http_message())
    |> validate_format(:socialize_url, Regexp.http(), message: Regexp.http_message())
    |> validate_published_has_published_at()
    |> validate_all_email_fields_together()
    |> validate_audio_file_no_plusplus()
    |> validate_plusplus_file_yes_plusplus()
    |> unique_constraint(:slug, name: :episodes_slug_podcast_id_index)
    |> cast_assoc(:episode_hosts)
    |> cast_assoc(:episode_guests)
    |> cast_assoc(:episode_sponsors)
    |> cast_assoc(:episode_topics)
  end

  def get_news_item(episode) do
    episode
    |> NewsItem.with_episode()
    |> Repo.one()
  end

  def has_news_item(episode) do
    episode
    |> NewsItem.with_episode()
    |> Repo.exists?()
  end

  def load_news_item(episode) do
    item = episode |> get_news_item() |> NewsItem.load_object(episode)
    Map.put(episode, :news_item, item)
  end

  def object_id(episode), do: "#{episode.podcast_id}:#{episode.id}"

  def participants(episode) do
    episode =
      if Ecto.assoc_loaded?(episode.guests) and Ecto.assoc_loaded?(episode.hosts) do
        episode
      else
        episode
        |> preload_guests()
        |> preload_hosts()
      end

    episode.guests ++ episode.hosts
  end

  def preload_all(episode) do
    episode
    |> preload_podcast()
    |> preload_topics()
    |> preload_guests()
    |> preload_hosts()
    |> preload_sponsors()
    |> preload_episode_request()
  end

  def preload_episode_request(query = %Ecto.Query{}),
    do: Ecto.Query.preload(query, :episode_request)

  def preload_episode_request(episode), do: Repo.preload(episode, :episode_request)

  def preload_hosts(query = %Ecto.Query{}) do
    query
    |> Ecto.Query.preload(episode_hosts: ^EpisodeHost.by_position())
    |> Ecto.Query.preload(:hosts)
  end

  def preload_hosts(episode) do
    episode
    |> Repo.preload(episode_hosts: {EpisodeHost.by_position(), :person})
    |> Repo.preload(:hosts)
  end

  def preload_guests(query = %Ecto.Query{}) do
    query
    |> Ecto.Query.preload(episode_guests: ^EpisodeGuest.by_position())
    |> Ecto.Query.preload(:guests)
  end

  def preload_guests(episode) do
    episode
    |> Repo.preload(episode_guests: {EpisodeGuest.by_position(), :person})
    |> Repo.preload(:guests)
  end

  def preload_podcast(nil), do: nil
  def preload_podcast(query = %Ecto.Query{}), do: Ecto.Query.preload(query, :podcast)
  def preload_podcast(episode), do: Repo.preload(episode, :podcast)

  def preload_sponsors(query = %Ecto.Query{}) do
    query
    |> Ecto.Query.preload(episode_sponsors: ^EpisodeSponsor.by_position())
    |> Ecto.Query.preload(:sponsors)
  end

  def preload_sponsors(episode) do
    episode
    |> Repo.preload(episode_sponsors: {EpisodeSponsor.by_position(), :sponsor})
    |> Repo.preload(:sponsors)
  end

  def preload_topics(query = %Ecto.Query{}) do
    query
    |> Ecto.Query.preload(episode_topics: ^EpisodeTopic.by_position())
    |> Ecto.Query.preload(:topics)
  end

  def preload_topics(episode) do
    episode
    |> Repo.preload(episode_topics: {EpisodeTopic.by_position(), :topic})
    |> Repo.preload(:topics)
  end

  def sponsors_duration(%{episode_sponsors: []}), do: 0

  def sponsors_duration(episode = %{episode_sponsors: sponsors}) do
    # A sponsor on an episode with chapters *should* have timestamps. When they
    # don't, it's because they're only nominal sponsors, so have a 0 duration.
    # When the episode doesn't have chapters, we guesstimate they're 60 secs
    default_duration = if Enum.any?(episode.audio_chapters), do: 0, else: 60
    sponsors |> Enum.map(fn s -> sponsor_duration(s, default_duration) end) |> Enum.sum()
  end

  defp sponsor_duration(sponsor, default) do
    if sponsor.starts_at && sponsor.ends_at do
      round(sponsor.ends_at - sponsor.starts_at)
    else
      default
    end
  end

  def update_stat_counts(episode) do
    stats = Repo.all(assoc(episode, :episode_stats))

    new_downloads =
      stats
      |> Enum.map(& &1.downloads)
      |> Enum.sum()
      |> Kernel.+(episode.import_count)
      |> Kernel./(1)
      |> Float.round(2)

    new_reach =
      stats
      |> Enum.map(& &1.uniques)
      |> Enum.sum()

    episode
    |> change(%{download_count: new_downloads, reach_count: new_reach})
    |> Repo.update!()
  end

  def update_email_stats(episode) do
    episode = preload_podcast(episode)
    group = "#{episode.podcast.name} #{episode.slug}"
    %{"Delivered" => sends, "Opened" => opens} = Craisin.Client.stats(group)

    episode
    |> change(%{email_sends: sends, email_opens: opens})
    |> Repo.update!()
  end

  def update_notes(episode, text) do
    episode
    |> change(notes: text)
    |> Repo.update!()
  end

  def socialize_url(episode, url) do
    episode
    |> change(socialize_url: url)
    |> Repo.update!()
  end

  def update_transcript(episode, text) do
    case Transcripts.Parser.parse_text(text, participants(episode)) do
      {:ok, parsed} ->
        changeset = change(episode, transcript: parsed)

        if Enum.any?(changeset.changes) do
          Logger.info("Transcript: refreshing episode ##{episode.id}")
        end

        updated = Repo.update!(changeset)

        if !has_transcript(episode) && has_transcript(updated) do
          Task.start_link(fn -> Notifier.notify(updated) end)
        end

        Task.start_link(fn -> TypesenseSearch.save_item(updated) end)

        updated

      {:error, e} ->
        source = Github.Source.new("transcripts", episode)
        Github.Issuer.create(source, e)
        episode
    end
  end

  def purge_audio_when_slug_changes(changeset) do
    if Map.has_key?(changeset.changes, :slug) do
      changeset
      |> change(%{
        audio_file: nil,
        audio_bytes: nil,
        audio_duration: nil,
        plusplus_file: nil,
        plusplus_bytes: nil,
        plusplus_duration: nil
      })
    else
      changeset
    end
  end

  # We do all pre-processing of uploaded audio files here instead of in
  # Audio.transform/2 because we need to extract information from the
  # just-transformed files to store in the changeset, which cannot be
  # accomplished with Waffle at the time of implementation.
  def prep_audio_file(changeset, %{"audio_file" => %Plug.Upload{path: path}}) do
    Changelog.Mp3Kit.tag(path, changeset.data, changeset.data.audio_chapters)

    case File.stat(path) do
      {:ok, stats} ->
        seconds = Changelog.Mp3Kit.get_duration(path)
        change(changeset, audio_bytes: stats.size, audio_duration: seconds)

      {:error, _} ->
        changeset
    end
  end

  def prep_audio_file(changeset, _params), do: changeset

  def prep_plusplus_file(changeset, %{"plusplus_file" => %Plug.Upload{path: path}}) do
    Changelog.Mp3Kit.tag(path, changeset.data, changeset.data.plusplus_chapters)

    case File.stat(path) do
      {:ok, stats} ->
        seconds = Changelog.Mp3Kit.get_duration(path)
        change(changeset, plusplus_bytes: stats.size, plusplus_duration: seconds)

      {:error, _} ->
        changeset
    end
  end

  def prep_plusplus_file(changeset, _params), do: changeset

  def attrs_with_chapters_sorted_by_starts_at(attrs) do
    attrs
    |> sort_all_by_starts_at("audio_chapters")
    |> sort_all_by_starts_at("plusplus_chapters")
  end

  defp sort_all_by_starts_at(attrs, key) do
    try do
      Map.update!(attrs, key, fn chapters ->
        chapters
        |> Map.values()
        |> Enum.sort(&(Float.parse(&1["starts_at"]) <= Float.parse(&2["starts_at"])))
        |> Enum.with_index()
        |> Map.new(fn {chapter, index} -> {"#{index}", chapter} end)
      end)
    rescue
      KeyError -> attrs
    end
  end

  defp validate_published_has_published_at(changeset) do
    published = get_field(changeset, :published)
    published_at = get_field(changeset, :published_at)

    if published && is_nil(published_at) do
      add_error(changeset, :published_at, "can't be blank when published")
    else
      changeset
    end
  end

  defp validate_all_email_fields_together(changeset) do
    content = get_field(changeset, :email_content)
    subject = get_field(changeset, :email_subject)
    teaser = get_field(changeset, :email_teaser)

    if content && (is_nil(subject) || is_nil(teaser)) do
      add_error(changeset, :email_content, "other email fields must be filled")
    else
      changeset
    end
  end

  defp validate_audio_file_no_plusplus(changeset) do
    audio_file = get_field(changeset, :audio_file)

    if audio_file && String.contains?(audio_file.file_name, "++") do
      add_error(changeset, :audio_file, "this looks like a ++ mp3 (filename)")
    else
      changeset
    end
  end

  defp validate_plusplus_file_yes_plusplus(changeset) do
    plusplus_file = get_field(changeset, :plusplus_file)

    if plusplus_file && !String.contains?(plusplus_file.file_name, "++") do
      add_error(changeset, :plusplus_file, "this doesn't look like a ++ mp3 (filename)")
    else
      changeset
    end
  end
end
