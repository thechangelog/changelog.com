defmodule Changelog.Files.Logo do
  defmacro __using__(prefix) do
    quote do
      use Changelog.File, [:jpg, :jpeg, :png, :svg]
      use Arc.Definition
      use Arc.Ecto.Definition

      @versions [:original, :large, :medium, :small]

      def filename(version, _) do
        "#{unquote(prefix)}_logo_#{version}"
      end

      def storage_dir(_version, {_file, scope}) do
        hashed_id = Changelog.Hashid.encode(scope.id)
        "#{Application.fetch_env!(:arc, :storage_dir)}/logos/#{hashed_id}"
      end

      def transform(version, {file, _scope}) do
        if file_type(file) == :svg do
          :noaction
        else
          {:convert, "-strip -resize #{dimensions(version)} -format png", :png}
        end
      end

      defp dimensions(:large), do: "800x800"
      defp dimensions(:medium), do: "400x400"
      defp dimensions(:small), do: "200x200"
    end
  end
end

defmodule Changelog.Files.ColorLogo do
  use Changelog.Files.Logo, "color"
end

defmodule Changelog.Files.DarkLogo do
  use Changelog.Files.Logo, "dark"
end

defmodule Changelog.Files.LightLogo do
  use Changelog.Files.Logo, "light"
end
