defmodule Changelog.Files.Avatar do
  use Changelog.File, [:jpg, :jpeg, :png]

  @versions [:original, :large, :medium, :small]

  def storage_dir(_version, {_file, scope}), do: expanded_dir("/avatars/#{source(scope)}/#{hashed(scope.id)}")
  def filename(version, _), do: "avatar_#{version}"

  def transform(version, _) do
    {:convert, "-strip -resize #{dimensions(version)} -format png", :png}
  end

  defp dimensions(:large), do: "600x600"
  defp dimensions(:medium), do: "300x300"
  defp dimensions(:small), do: "150x150"
end
