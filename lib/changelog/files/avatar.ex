defmodule Changelog.Files.Avatar do
  use Changelog.File, [:jpg, :jpeg, :png]

  @versions [:original, :large, :medium, :small, :thumb]

  def storage_dir(_version, {_file, scope}),
    do: "uploads/avatars/#{source(scope)}/#{hashed(scope.id)}"

  def filename(version, _), do: "avatar_#{version}"

  def transform(:original, _), do: :noaction

  def transform(version, {_file, _scope}) do
    args = [
      "-resize #{dimensions(version)}^",
      "-gravity center",
      "-crop #{dimensions(version)}+0+0",
    ]

    {:convert, convert_args(args)}
  end

  defp dimensions(:large), do: "600x600"
  defp dimensions(:medium), do: "300x300"
  defp dimensions(:small), do: "150x150"
  defp dimensions(:thumb), do: "50x50"
end
