defmodule Changelog.Person do
  use Changelog.Web, :model

  schema "people" do
    field :name, :string
    field :email, :string
    field :handle, :string
    field :github_handle, :string
    field :twitter_handle, :string
    field :website, :string
    field :bio, :string
    field :auth_token, :string
    field :auth_token_expires_at, Ecto.DateTime
    field :signed_in_at, Ecto.DateTime

    timestamps
  end

  @admins ~w(jerod@changelog.com adam@changelog.com)
  @required_fields ~w(name email handle)
  @optional_fields ~w(github_handle twitter_handle bio website)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_format(:website, ~r/^https?:\/\//, message: "must include http(s)://")
    |> validate_format(:handle, ~r/\A[a-z|0-9|_|-]+\z/, message: "valid chars: a-z, 0-9, -, _")
    |> validate_length(:handle, max: 40, message: "max 40 chars")
    |> unique_constraint(:name)
    |> unique_constraint(:email)
    |> unique_constraint(:handle)
  end

  def is_admin(model) do
    Enum.member? @admins, model.email
  end
end
