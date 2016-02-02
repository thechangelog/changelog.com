defmodule Changelog.Repo do
  use Ecto.Repo, otp_app: :changelog
  use Scrivener, page_size: 25
end
