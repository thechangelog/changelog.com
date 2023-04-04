defmodule Changelog.Repo.Migrations.AddEpisodeEmailFields do
  use Ecto.Migration

  def change do
    alter table(:episodes) do
      add(:email_subject, :string)
      add(:email_content, :text)
      add(:email_teaser, :string)
      add(:email_sends, :integer, default: 0)
      add(:email_opens, :integer, default: 0)
    end
  end
end
