defmodule Changelog.Stats.S3 do
  def config do
    [
      access_key_id: SecretOrEnv.get("AWS_ACCESS_KEY_ID"),
      secret_access_key: SecretOrEnv.get("AWS_SECRET_ACCESS_KEY"),
      host: SecretOrEnv.get("AWS_API_HOST")
    ]
  end

  def get_logs(date, slug) do
    bucket = "changelog-logs-#{slug}"

    list_logs(bucket, date)
    |> Task.async_stream(fn %{key: key} -> get_log(bucket, key) end)
    |> Enum.map(fn {:ok, log} -> log end)
  end

  defp get_log(bucket, key) do
    ExAws.S3.get_object(bucket, key)
    |> ExAws.request!(config())
    |> Map.get(:body)
  end

  @doc """
  returns a list of log object data for a given bucket and prefix, continuing
  past the S3's 1000 key limit when necessary
  """
  def list_logs(bucket, prefix, next \\ nil, accumulated \\ []) do
    options = if next, do: [prefix: prefix, continuation_token: next], else: [prefix: prefix]
    request = ExAws.S3.list_objects_v2(bucket, options)

    case ExAws.request!(request, config()) do
      %{body: %{is_truncated: "false", contents: contents}} ->
        accumulated ++ contents
      %{body: %{next_continuation_token: next, contents: contents}} ->
        list_logs(bucket, prefix, next, accumulated ++ contents)
    end
  end
end
