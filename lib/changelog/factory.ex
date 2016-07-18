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

  def published_episode_factory do
    %Changelog.Episode{
      title: sequence(:title, &"Best Show Evar! #{&1}"),
      slug: sequence(:slug, &"best-show-evar-#{&1}"),
      audio_file: %{file_name: "test.mp3", updated_at: Ecto.DateTime.from_erl(:calendar.gregorian_seconds_to_datetime(63633830567))},
      published: true,
      podcast: build(:podcast)
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

  def sponsor_factory do
    %Changelog.Sponsor{
      name: sequence(:name, &"Sponsor #{&1}")
    }
  end
end
