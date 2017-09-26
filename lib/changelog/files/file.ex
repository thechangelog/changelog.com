defmodule Changelog.File do
  defmacro __using__(types) do
    quote do
      def __storage, do: Arc.Storage.Local

      def default_url(_version, _scope) do
        "/images/defaults/black.png"
      end

      def validate({file, _}) do
        Enum.member?(unquote(types), file_type(file))
      end

      defp file_type(file) do
        file.file_name
        |> Path.extname
        |> String.replace(".", "")
        |> String.downcase
        |> String.to_atom
      end
    end
  end
end
