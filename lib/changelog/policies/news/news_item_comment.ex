defmodule Changelog.Policies.NewsItemComment do
  use Changelog.Policies.Default

  def update(
        %Changelog.Person{id: user_id},
        %Changelog.NewsItemComment{author_id: author_id, inserted_at: comment_inserted_at}
      ) do
    time_since_post = NaiveDateTime.diff(NaiveDateTime.utc_now(), comment_inserted_at, :second)

    user_id == author_id and time_since_post < 300
  end

  def update(_, _) do
    false
  end
end
