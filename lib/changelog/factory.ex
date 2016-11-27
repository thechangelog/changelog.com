defmodule Changelog.Factory do
  use ExMachina.Ecto, repo: Changelog.Repo

  def channel_factory do
    %Changelog.Channel{
      name: sequence(:name, &"Channel #{&1}"),
      slug: sequence(:slug, &"channel-#{&1}")
    }
  end

  def episode_factory do
    %Changelog.Episode{
      title: sequence(:title, &"Best Show Evar! #{&1}"),
      slug: sequence(:slug, &"best-show-evar-#{&1}"),
      podcast: build(:podcast)
    }
  end

  def episode_stat_factory do
    %Changelog.EpisodeStat{
      date: Timex.today,
      episode: build(:episode),
      podcast: build(:podcast),
      downloads: 0.0,
      uniques: 0,
      demographics: %{"agents" => %{}, "countries" => %{}}
    }
  end

  def episode_guest_factory do
    %Changelog.EpisodeGuest{
      episode: build(:episode),
      person: build(:person),
      position: 1
    }
  end

  def episode_host_factory do
    %Changelog.EpisodeHost{
      episode: build(:episode),
      person: build(:person),
      position: 1
    }
  end

  def episode_sponsor_factory do
    %Changelog.EpisodeSponsor{
      episode: build(:episode),
      sponsor: build(:sponsor),
      title: "Google",
      link_url: "https://google.com",
      description: "Don't be evil",
      position: 1
    }
  end

  def published_episode_factory do
    %Changelog.Episode{episode_factory | audio_file: stub_audio_file(),
      published: true,
      published_at: Timex.subtract(Timex.now, Timex.Duration.from_hours(1))
    }
  end

  def scheduled_episode_factory do
    %Changelog.Episode{episode_factory | audio_file: stub_audio_file(),
      published: true,
      published_at: Timex.add(Timex.now, Timex.Duration.from_hours(1))
    }
  end

  def person_factory do
    %Changelog.Person{
      name: sequence(:name, &"Joe Blow #{&1}"),
      email: sequence(:email, &"joe-#{&1}@email.com"),
      handle: sequence(:handle, &"joeblow-#{&1}")
    }
  end

  def podcast_factory do
    %Changelog.Podcast{
      name: sequence(:name, &"Show #{&1}"),
      slug: sequence(:slug, &"show-#{&1}"),
      status: :published
    }
  end

  def post_factory do
    %Changelog.Post{
      title: sequence(:name, &"Post #{&1}"),
      slug: sequence(:slug, &"post-#{&1}"),
      author: build(:person)
    }
  end

  def published_post_factory do
    published_at = Timex.subtract(Timex.now, Timex.Duration.from_hours(1))
    %Changelog.Post{post_factory | published: true, published_at: published_at}
  end

  def scheduled_post_factory do
    published_at = Timex.add(Timex.now, Timex.Duration.from_hours(1))
    %Changelog.Post{post_factory | published: true, published_at: published_at}
  end

  def sponsor_factory do
    %Changelog.Sponsor{
      name: sequence(:name, &"Sponsor #{&1}")
    }
  end

  defp stub_audio_file do
    %{file_name: "test.mp3", updated_at: Ecto.DateTime.from_erl(:calendar.gregorian_seconds_to_datetime(63_633_830_567))}
  end
end
