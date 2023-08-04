defmodule Changelog.Stats.S3 do
  @config [
      access_key_id: SecretOrEnv.get("AWS_ACCESS_KEY_ID"),
      secret_access_key: SecretOrEnv.get("AWS_SECRET_ACCESS_KEY"),
      host: SecretOrEnv.get("AWS_API_HOST")
    ]

  def get_logs(date, slug) do
    bucket = "changelog-logs-#{slug}"

    ExAws.S3.list_objects(bucket, prefix: date)
    |> ExAws.request!(@config)
    |> get_in([:body, :contents])
    |> Task.async_stream(fn %{key: key} -> get_log(bucket, key) end)
    |> Enum.map(fn {:ok, log} -> log end)
  end

  defp get_log(bucket, key) do
    ExAws.S3.get_object(bucket, key)
    |> ExAws.request!(@config)
    |> Map.get(:body)
  end
end
