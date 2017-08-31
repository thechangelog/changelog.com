defmodule Changelog.Data do
  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema
      use Arc.Ecto.Schema
      use Timex.Ecto.Timestamps

      import Ecto
      import Ecto.Changeset
      import Ecto.Query, only: [from: 1, from: 2]
      import EctoEnum, only: [defenum: 2]

      alias Changelog.Repo
      alias Timex.Ecto.DateTime
    end
  end
end
