defmodule Changelog.Stats.S3 do
  def get_logs(date, slug) do
    bucket = "changelog-logs-#{slug}"

    ExAws.S3.list_objects(bucket, prefix: date)
    |> ExAws.request!()
    |> get_in([:body, :contents])
    |> Task.async_stream(fn(%{key: key}) -> get_log(bucket, key) end)
    |> Enum.map(fn({:ok, log}) -> log end)
  end

  defp get_log(bucket, key) do
    ExAws.S3.get_object(bucket, key)
    |> ExAws.request!()
    |> Map.get(:body)
  end
end
