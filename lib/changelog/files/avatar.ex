defmodule Changelog.Files.Avatar do
  use Changelog.File, [:jpg, :jpeg, :png]
  use Arc.Definition
  use Arc.Ecto.Definition

  @versions [:original, :large, :medium, :small]

  def storage_dir(_version, {_file, scope}) do
    hashed_id = Changelog.Hashid.encode(scope.id)
    "#{Application.fetch_env!(:arc, :storage_dir)}/avatars/#{hashed_id}"
  end

  def filename(version, _) do
    "avatar_#{version}"
  end

  def transform(version, _) do
    {:convert, "-strip -resize #{dimensions(version)} -format png", :png}
  end

  defp dimensions(:large), do: "600x600"
  defp dimensions(:medium), do: "300x300"
  defp dimensions(:small), do: "150x150"
end
