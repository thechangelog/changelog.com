defmodule Changelog.NewsItem do
  use Changelog.Data

  alias Changelog.{Regexp}

  defenum Status, draft: 0, queued: 1, published: 2, declined: 3
  defenum Type, link: 0, audio: 1, video: 2, project: 3, announcement: 4

  schema "" do
    field :status, Status
    field :type, Type

    field :url, :string
    field :headline, :string
    field :story, :string
    # field :image, Icon.Type

    field :published_at, DateTime

    belongs_to :author, Person
    belongs_to :source, NewsSource
  end

  def admin_changeset(news_item, attrs \\ %{}) do
    news_item
    # |> cast_attachments(attrs, ~w(image))
    |> cast(attrs, ~w(status type url headline story published_at author_id source_id))
    |> validate_required([:status, :type, :url, :headline])
    |> validate_format(:url, Regexp.http, message: Regexp.http_message)
  end
end
