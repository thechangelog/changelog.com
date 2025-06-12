defmodule Changelog.ObanWorkers.ContentPurger do
  @moduledoc """
  This module defines the Oban worker for purging CDN content
  """
  use Oban.Worker

  alias Changelog.{
    Episode,
    EventLog,
    Fastly,
    Files,
    NewsItem,
    NewsSource,
    Person,
    Pipedream,
    Podcast,
    Post,
    Repo,
    Sponsor,
    Topic
  }

  alias ChangelogWeb.{
    EpisodeView,
    NewsItemView,
    NewsSourceView,
    PersonView,
    PodcastView,
    PostView,
    SponsorView,
    TopicView
  }

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"episode_id" => id}}) do
    episode = Episode |> Repo.get(id) |> Episode.preload_all()

    if episode.audio_file do
      episode |> EpisodeView.audio_direct_url() |> purge()
    end

    if episode.plusplus_file do
      episode |> EpisodeView.plusplus_url() |> purge()
    end

    if episode.cover do
      for version <- Files.Cover.__versions() do
        episode |> EpisodeView.cover_url(version) |> purge()
      end
    end
  end

  def perform(%Oban.Job{args: %{"news_item_id" => id}}) do
    item = NewsItem |> Repo.get(id) |> NewsItem.preload_all()

    if item.image do
      for version <- Files.Image.__versions() do
        item |> NewsItemView.image_url(version) |> purge()
      end
    end
  end

  def perform(%Oban.Job{args: %{"news_source_id" => id}}) do
    source = NewsSource |> Repo.get(id)

    if source.icon do
      for version <- Files.Image.__versions() do
        source |> NewsSourceView.icon_url(version) |> purge()
      end
    end
  end

  def perform(%Oban.Job{args: %{"person_id" => id}}) do
    person = Person |> Repo.get(id)

    if person.avatar do
      for version <- Files.Avatar.__versions() do
        person |> PersonView.avatar_url(version) |> purge()
      end
    end
  end

  def perform(%Oban.Job{args: %{"podcast_id" => id}}) do
    podcast = Podcast |> Repo.get(id)

    if podcast.cover do
      for version <- Files.Cover.__versions() do
        podcast |> PodcastView.cover_url(version) |> purge()
      end
    end
  end

  def perform(%Oban.Job{args: %{"post_id" => id}}) do
    post = Post |> Repo.get(id)

    if post.image do
      for version <- Files.Image.__versions() do
        post |> PostView.image_url(version) |> purge()
      end
    end
  end

  def perform(%Oban.Job{args: %{"sponsor_id" => id}}) do
    sponsor = Sponsor |> Repo.get(id)

    if sponsor.avatar do
      for version <- Files.Avatar.__versions() do
        sponsor |> SponsorView.avatar_url(version) |> purge()
      end
    end

    if sponsor.color_logo do
      for version <- Files.ColorLogo.__versions() do
        sponsor |> SponsorView.logo_url(:color_logo, version) |> purge()
      end
    end

    if sponsor.dark_logo do
      for version <- Files.DarkLogo.__versions() do
        sponsor |> SponsorView.logo_url(:dark_logo, version) |> purge()
      end
    end

    if sponsor.light_logo do
      for version <- Files.LightLogo.__versions() do
        sponsor |> SponsorView.logo_url(:light_logo, version) |> purge()
      end
    end
  end

  def perform(%Oban.Job{args: %{"topic_id" => id}}) do
    topic = Topic |> Repo.get(id)

    if topic.icon do
      for version <- Files.Image.__versions() do
        topic |> TopicView.icon_url(version) |> purge()
      end
    end
  end

  def perform(%Oban.Job{args: %{"url" => url}}) do
    purge(url)
  end

  def queue(struct) when is_map(struct) do
    key =
      case struct do
        %Episode{} -> "episode_id"
        %NewsItem{} -> "news_item_id"
        %NewsSource{} -> "news_source_id"
        %Person{} -> "person_id"
        %Podcast{} -> "podcast_id"
        %Post{} -> "post_id"
        %Sponsor{} -> "sponsor_id"
        %Topic{} -> "topic_id"
      end

    %{key => struct.id} |> new() |> Oban.insert()
  end

  def queue(url) when is_binary(url) do
    %{"url" => url} |> new() |> Oban.insert()
  end

  defp purge(url) do
    EventLog.insert("Purging URL: #{url}", "ContentPurger")

    Fastly.purge(url)
    Pipedream.purge(url)
  end
end
