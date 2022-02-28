defmodule Changelog.Files.Logo do
  defmacro __using__(prefix) do
    quote do
      use Changelog.File, [:jpg, :jpeg, :png, :svg]

      @versions [:original, :large, :medium, :small]

      def storage_dir(_, {_, scope}), do: "uploads/logos/#{hashed(scope.id)}"
      def filename(version, _), do: "#{unquote(prefix)}_logo_#{version}"

      def transform(:original, _), do: :noaction

      def transform(version, {file, _scope}) do
        if file_type(file) == :svg do
          :noaction
        else
          {:convert, convert_args("-resize #{dimensions(version)}")}
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
