defmodule Changelog.LogoImage do
  use Arc.Definition
  use Arc.Ecto.Definition

  @versions [:original, :large, :medium, :small]

  def __storage, do: Arc.Storage.Local

  def validate({file, _}) do
    ~w(.jpg .png) |> Enum.member?(Path.extname(file.file_name))
  end

  def storage_dir(_version, {_file, scope}) do
    hashed_id = Changelog.Hashid.encode(scope.id)
    "priv/static/uploads/logos/#{hashed_id}"
  end

  def filename(version, _) do
    "logo_#{version}"
  end

  def transform(:large, _) do
    {:convert, "-strip -resize 800x800 -format png", :png}
  end

  def transform(:medium, _) do
    {:convert, "-strip -resize 400x400 -format png", :png}
  end

  def transform(:small, _) do
    {:convert, "-strip -resize 200x200 -format png", :png}
  end

  def default_url(_version, _scope) do
    "/images/defaults/black.png"
  end
end
