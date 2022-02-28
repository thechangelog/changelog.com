defmodule Changelog.Files.Icon do
  use Changelog.File, [:jpg, :jpeg, :png, :svg]

  @versions [:original, :large, :medium, :small]

  def storage_dir(_, {_, scope}), do: "uploads/icons/#{source(scope)}/#{hashed(scope.id)}"
  def filename(version, _), do: "icon_#{version}"

  def transform(:original, _), do: :noaction

  def transform(version, {file, _scope}) do
    if file_type(file) == :svg do
      :noaction
    else
      {:convert, convert_args("-resize #{dimensions(version)}")}
    end
  end

  defp dimensions(:large), do: "600x600"
  defp dimensions(:medium), do: "300x300"
  defp dimensions(:small), do: "150x150"
end
