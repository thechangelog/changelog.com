defmodule Changelog.Files.Image do
  use Changelog.File, [:jpg, :jpeg, :png, :gif]

  @versions [:original, :large, :medium, :small]

  def storage_dir(_, {_, scope}), do: expanded_dir("/#{source(scope)}/#{hashed(scope.id)}")
  def filename(version, _), do: version

  def transform(:original, _), do: :noaction
  def transform(version, {file, _scope}) do
    if file_type(file) == :gif do
      :noaction
    else
      {:convert, "-strip -resize #{dimensions(version)}"}
    end
  end

  defp dimensions(:large), do: "1200>"
  defp dimensions(:medium), do: "600>"
  defp dimensions(:small), do: "300>"
end
