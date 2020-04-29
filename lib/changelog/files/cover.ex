defmodule Changelog.Files.Cover do
  use Changelog.File, [:jpg, :png]

  alias ChangelogWeb.PodcastView

  @versions [:original, :medium, :small]

  def storage_dir(_, _), do: expanded_dir("/covers")
  def filename(version, {_, scope}), do: "#{PodcastView.dasherized_name(scope)}-#{version}"

  def transform(:original, _), do: :noaction
  def transform(version, {_file, _scope}) do
    {:convert, "-strip -resize #{dimensions(version)}"}
  end

  # defp dimensions(:original),  do: "3000x3000"
  defp dimensions(:medium), do: "440x440"
  defp dimensions(:small),  do: "100x100"
end
