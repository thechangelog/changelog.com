defmodule Changelog.Avatar do
  use Arc.Definition
  use Arc.Ecto.Definition

  @versions [:original, :large, :medium, :small]

  def __storage, do: Arc.Storage.Local

  def validate({file, _}) do
    Enum.member?(~w(.jpg .jpeg .png), file_ext(file))
  end

  def storage_dir(_version, {_file, scope}) do
    hashed_id = Changelog.Hashid.encode(scope.id)
    "#{Application.fetch_env!(:arc, :storage_dir)}/avatars/#{hashed_id}"
  end

  def filename(version, _) do
    "avatar_#{version}"
  end

  def transform(:large, _) do
    {:convert, "-strip -resize 600x600 -format png", :png}
  end

  def transform(:medium, _) do
    {:convert, "-strip -resize 300x300 -format png", :png}
  end

  def transform(:small, _) do
    {:convert, "-strip -resize 150x150 -format png", :png}
  end

  def default_url(_version, _scope) do
    "/images/defaults/black.png"
  end

  defp file_ext(file) do
    file.file_name |> Path.extname |> String.downcase
  end
end
