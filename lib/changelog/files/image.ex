defmodule Changelog.Files.Image do
  use Changelog.File, [:jpg, :jpeg, :png, :gif, :svg, :webp]

  @versions [:original, :large, :medium, :small]

  def storage_dir(_, {_, scope}), do: "uploads/#{source(scope)}/#{hashed(scope.id)}"
  def filename(version, _), do: version

  def transform(:original, _), do: :noaction

  def transform(version, {file, _scope}) do
    case file_type(file) do
      :gif -> :noaction
      :svg -> :noaction
      _ -> {:convert, convert_args("-resize #{dimensions(version)}")}
    end
  end

  defp dimensions(:large), do: "1200>"
  defp dimensions(:medium), do: "600>"
  defp dimensions(:small), do: "300>"
end
