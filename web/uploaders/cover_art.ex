defmodule Changelog.CoverArt do
  use Arc.Definition
  use Arc.Ecto.Definition

  @versions [:original, :large, :medium, :small]

  def __storage, do: Arc.Storage.Local

  def validate({file, _}) do
    ~w(.jpg .png) |> Enum.member?(Path.extname(file.file_name))
  end

  def storage_dir(_version, {_file, scope}) do
    "priv/static/uploads/#{scope.slug}"
  end

  def filename(version, _) do
    "cover_#{version}"
  end

  def transform(:large, _) do
    {:convert, "-strip -resize 1500x1500 -format png", :png}
  end

  def transform(:medium, _) do
    {:convert, "-strip -resize 750x750 -format png", :png}
  end

  def transform(:small, _) do
    {:convert, "-strip -resize 300x300 -format png", :png}
  end

  def default_url(_version, _scope) do
    "/images/defaults/cover.png"
  end
end
