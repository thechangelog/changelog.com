
defmodule Changelog.Mp3Kit do
  @doc """
  Returns duration in seconds, given mp3 data or a valid path to an mp3 file
  (yoinked from https://gist.github.com/kommen/9391eb6391d76c2b42c0402fc5ca7353)
  """
  def get_duration(data_or_path) do
    data = if String.valid?(data_or_path) do
      File.read!(data_or_path)
    else
      data_or_path
    end

    data |> compute_duration(0, 0) |> round()
  end

  defp compute_duration(data, offset, duration) when byte_size(data) > offset do
    case decode_header_at_offset(offset, data) do
      {:ok, length, {samplerate, samples}} ->
        compute_duration(data, offset + length, duration + (samples / samplerate))
      _ ->
        compute_duration(data, offset + 1, duration)
    end
  end
  defp compute_duration(_data, _offset, duration) do
    Float.round(duration, 3)
  end

  defp decode_header_at_offset(offset, data) do
    try do
      binary_part(data, offset, 4)
      |> decode_header
    rescue
      ArgumentError -> {:error, "not enough bytes"}
    end
  end

  defp decode_header(<<255, 7::size(3),
    audio_version_id :: size(2), layer_desc :: size(2), _d :: size(1), bitrate_index :: size(4),
    sampling_rate_index :: size(2), padding :: size(1), bits :: size(9)>>) do

    with {:ok, version}     <- audio_version(audio_version_id),
         {:ok, layer}       <- layer(layer_desc),
         {:ok, bitrate}     <- bitrate(version, layer, bitrate_index),
         {:ok, samplerate}  <- samplerate(version, sampling_rate_index),
         {:ok, samples}     <- samples(version, layer),
         {:ok, framelength} <- framelength(layer, bitrate, samplerate, padding),
         do: {:ok, framelength, {samplerate, samples}}
  end
  defp decode_header(_a) do
    {:error, :invalid_header}
  end

  defp framelength(v, br, sr, p) do
    fl = compute_framelength(v, br, sr, p)
    if fl < 27 do
      {:error, "frame too short"}
    else
      {:ok, fl}
    end
  end
  defp compute_framelength(1, bitrate, samplerate, padding) do
    trunc(((12 * bitrate / samplerate) + padding) * 4)
  end
  defp compute_framelength(_, bitrate, samplerate, padding) do
    trunc((144 * bitrate / samplerate) + padding)
  end

  defp audio_version(audio_version_id) do
    case audio_version_id do
      0 -> {:ok, {2, 5}}
      2 -> {:ok, 2}
      3 -> {:ok, 1}
      1 -> {:error, "bad version"}
    end
  end

  defp layer(layer_desc) do
    case layer_desc do
      0 -> {:error, "bad layer"}
      1 -> {:ok, 3}
      2 -> {:ok, 2}
      3 -> {:ok, 1}
    end
  end

  defp bitrate(_, _, 15), do: {:error, "bad bitrate"}
  defp bitrate(v, l, e),  do: {:ok, bitrate_map(v, l, e) * 1000}
  defp bitrate_map(1, 1, e), do: elem({0,32,64,96,128,160,192,224,256,288,320,352,384,416,448}, e)
  defp bitrate_map(1, 2, e), do: elem({0,32,48,56,64,80,96,112,128,160,192,224,256,320,384}, e)
  defp bitrate_map(1, 3, e), do: elem({0,32,40,48,56,64,80,96,112,128,160,192,224,256,320}, e)
  defp bitrate_map(2, 1, e), do: elem({0,32,48,56,64,80,96,112,128,144,160,176,192,224,256}, e)
  defp bitrate_map(2, 2, e), do: elem({0,8,16,24,32,40,48,56,64,80,96,112,128,144,160}, e)
  defp bitrate_map(2, 3, e), do: bitrate_map(2, 2, e)
  defp bitrate_map({2,5}, l, e), do: bitrate_map(2, l, e)

  defp samplerate(1, 0), do: {:ok, 44100}
  defp samplerate(1, 1), do: {:ok, 48000}
  defp samplerate(1, 2), do: {:ok, 32000}
  defp samplerate(2, 0), do: {:ok, 22050}
  defp samplerate(2, 1), do: {:ok, 24000}
  defp samplerate(2, 2), do: {:ok, 16000}
  defp samplerate({2,5}, 0), do: {:ok, 11025}
  defp samplerate({2,5}, 1), do: {:ok, 12000}
  defp samplerate({2,5}, 2), do: {:ok, 8000}
  defp samplerate(_, _), do: {:error, "bad samplerate"}

  defp samples(1, 1), do: {:ok, 384}
  defp samples(1, 2), do: {:ok, 1152}
  defp samples(1, 3), do: {:ok, 1152}
  defp samples(2, 1), do: {:ok, 384}
  defp samples(2, 2), do: {:ok, 1152}
  defp samples(2, 3), do: {:ok, 576}
  defp samples({2,5}, l), do: samples(2, l)
end
