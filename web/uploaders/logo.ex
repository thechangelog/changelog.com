# note: THIS IS A HUGE HACK TO ACCOMPLISH WHAT IS BASICALLY INHERITANCE
# all I wanted to do was have different file names generated based on the
# sponsor `field` name assigned, but that appears to be impossible so I did
# this awful thing instead of duplicating all of this code in to 3 modules
# somebody please please please improve this
defmodule Changelog.Logo do
  defmacro __using__(_) do
    quote do
      use Arc.Definition
      use Arc.Ecto.Definition

      @versions [:original, :large, :medium, :small]

      def __storage, do: Arc.Storage.Local

      def validate({file, _}) do
        Enum.member?(~w(.jpg .png .svg), file_ext(file))
      end

      def storage_dir(_version, {_file, scope}) do
        hashed_id = Changelog.Hashid.encode(scope.id)
        Application.app_dir(:changelog, "priv/uploads/logos/#{hashed_id}")
      end

      def transform(:large, {file, _scope}) do
        if file_ext(file) == ".svg" do
          :noaction
        else
          {:convert, "-strip -resize 800x800 -format png", :png}
        end
      end

      def transform(:medium, {file, _scope}) do
        if file_ext(file) == ".svg" do
          :noaction
        else
          {:convert, "-strip -resize 400x400 -format png", :png}
        end
      end

      def transform(:small, {file, _scope}) do
        if file_ext(file) == ".svg" do
          :noaction
        else
          {:convert, "-strip -resize 200x200 -format png", :png}
        end
      end

      def default_url(_version, _scope) do
        "/images/defaults/black.png"
      end

      defp file_ext(file) do
        file.file_name |> Path.extname |> String.downcase
      end
    end
  end
end

defmodule Changelog.ColorLogo do
  use Changelog.Logo

  def filename(version, _) do
    "color_logo_#{version}"
  end
end

defmodule Changelog.DarkLogo do
  use Changelog.Logo

  def filename(version, _) do
    "dark_logo_#{version}"
  end
end

defmodule Changelog.LightLogo do
  use Changelog.Logo

  def filename(version, _) do
    "light_logo_#{version}"
  end
end
