defmodule Changelog.File do
  defmacro __using__(types) do
    quote do
      use Arc.Definition
      use Arc.Ecto.Definition

      def __storage, do: Arc.Storage.Local

      def default_url(_version, _scope) do
        "/images/defaults/black.png"
      end

      def expanded_dir(path) do
        Application.fetch_env!(:arc, :storage_dir) <> path
      end

      def validate({file, _}) do
        Enum.member?(unquote(types), file_type(file))
      end

      def transform(:original, _), do: :noaction

      defp file_type(file) do
        file.file_name
        |> Path.extname
        |> String.replace(".", "")
        |> String.downcase
        |> String.to_atom
      end

      defp hashed(id), do: Changelog.Hashid.encode(id)
      defp source(scope) do
        {_, source} = scope.__meta__.source
        source
      end
    end
  end
end
