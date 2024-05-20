defmodule Changelog.EventLog do
  use Changelog.Schema

  schema "event_logs" do
    field :caller, :string
    field :message, :string

    timestamps()
  end

  def insert(message, caller) do
    %Changelog.EventLog{}
    |> changeset(%{message: message, caller: caller})
    |> Repo.insert()
  end

  def changeset(event_log, attrs) do
    event_log
    |> cast(attrs, [:message, :caller])
    |> validate_required([:message, :caller])
  end
end
