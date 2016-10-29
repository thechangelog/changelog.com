defmodule Changelog.Stats.S3 do
  # downloads all of the log files for a given date/slug combo and returns
  # paths to temporary files holding data
  def logs(date, slug) do
    bucket = "changelog-logs-#{slug}"

    ExAws.S3.list_objects(bucket, prefix: date)
    |> ExAws.request!
    |> get_in([:body, :contents])
    |> Enum.map(&(&1.key))
    |> Enum.map(fn(log_key) -> download_log(bucket, log_key) end)
  end

  defp download_log(bucket, key) do
    {:ok, path} = Briefly.create
    ExAws.S3.download_file(bucket, key, path) |> ExAws.request!
    path
  end
end
