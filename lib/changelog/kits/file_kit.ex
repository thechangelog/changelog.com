defmodule Changelog.FileKit do
  @doc """
  If the file exists, we know it's a path to said file
  """
  def is_path?(binary), do: File.exists?(binary)

  @doc """
  Attempts to identify the file type, first by matching its magic number,
  if possible. Then it falls back to the file extension.
  """
  def get_type(binary) when is_binary(binary) do
    if is_path?(binary) do
      case File.read(binary) do
        {:ok, data} -> get_type(data)
        {:error, _e} -> :unknown
      end
    else
      case file_type_by_magic_number(binary) do
        :unknown -> file_type_by_extension(binary)
        type -> type
      end
    end
  end

  # Convenience wrappers around `get_type/1` for calling with form data/etc

  def get_type(%{file_name: file_name, path: nil}), do: get_type(file_name)
  # If we get a path, normalize it as `binary` and re-process
  def get_type(%{file_name: file_name, path: path}), do: get_type(%{file_name: file_name, binary: path})

  def get_type(%{file_name: file_name, binary: nil}), do: get_type(file_name)
  def get_type(%{file_name: file_name, binary: binary}) do
    case get_type(binary) do
      :unknown -> get_type(file_name)
      type -> type
    end
  end

  def get_type(%{file_name: file_name}), do: get_type(file_name)

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

  defp file_type_by_extension(binary) do
    cond do
      !String.valid?(binary) -> :unknown
      Path.extname(binary) == "" -> :unknown
      true -> string_to_extension(binary)
    end
  end

  defp string_to_extension(string) do
    string
    |> Path.extname()
    |> String.replace(".", "")
    |> String.downcase()
    |> String.to_existing_atom()
  end
end
