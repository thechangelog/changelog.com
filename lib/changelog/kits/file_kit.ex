defmodule Changelog.FileKit do
  @doc """
  Attempts to identify the file type, first by matching its magic number,
  if possible. Then it falls back to the file extension.
  """
  def get_type(path) when is_binary(path) do
    get_type(%{file_name: Path.basename(path), path: path})
  end
  def get_type(%{file_name: file_name, binary: content}) when is_binary(content) do
    case file_type_by_magic_number(content) do
      :unknown -> file_type_by_extension(file_name)
      type -> type
    end
  end
  def get_type(%{file_name: file_name, path: path}) when is_binary(path) do
    case file_type_by_magic_number(File.read!(path)) do
      :unknown -> file_type_by_extension(file_name)
      type -> type
    end
  end
  def get_type(%{file_name: file_name}) when is_binary(file_name) do
    file_type_by_extension(file_name)
  end

  @doc """
  Returns the appropriate mime type based on the file's type
  """
  def mime_type(file) do
    case get_type(file) do
      :jpg -> "image/jpg"
      :jpeg -> "image/jpg"
      :png -> "image/png"
      :gif -> "image/gif"
      :mp3 -> "audio/mpeg"
      :svg -> "image/svg+xml"
      _else -> "unknown"
    end
  end

  defp file_type_by_magic_number("GIF87a" <> _rest), do: :gif
  defp file_type_by_magic_number("GIF89a" <> _rest), do: :gif
  defp file_type_by_magic_number(<<0xff, 0xd8, 0xff>> <> _rest), do: :jpg
  defp file_type_by_magic_number("<svg" <> _rest), do: :svg
  defp file_type_by_magic_number(<<0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a>> <> _rest), do: :png
  defp file_type_by_magic_number(_), do: :unknown

  defp file_type_by_extension(file_name) do
    file_name
    |> Path.extname()
    |> String.replace(".", "")
    |> String.downcase()
    |> String.to_existing_atom()
  end
end
