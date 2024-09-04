defmodule Changelog.S3Static do
  require Logger
  import MIME, only: [from_path: 1]

  @doc "Functions for managing static files on S3"

  @s3_path "static"
  @app_path "priv/static"

  def upload_static_files_to_s3 do
    s3_bucket = System.get_env("R2_ASSETS_BUCKET")
    static_path = Path.join(Application.app_dir(:changelog), @app_path)

    static_path
    |> local_files_from_manifest()
    |> Task.async_stream(&put_file(&1, s3_bucket, @s3_path), max_concurrency: 10)
    |> Stream.run()
  end

  def delete_unused_files_from_s3 do
    s3_bucket = System.get_env("R2_ASSETS_BUCKET")
    static_path = Path.join(Application.app_dir(:changelog), @app_path)

    latest_files =
      static_path
      |> local_files_from_manifest()
      |> Enum.map(&Map.get(&1, :key))

    s3_bucket
    |> s3_files_from_bucket(@s3_path)
    |> Enum.reject(fn s3_file ->
      key = String.trim_leading(s3_file.key, "#{@s3_path}/")
      Enum.member?(latest_files, key)
    end)
    |> Enum.each(&delete_file(&1, s3_bucket))
  end

  def local_files_from_manifest(path) do
    path
    |> Path.join("cache_manifest.json")
    |> File.read!()
    |> Phoenix.json_library().decode!()
    |> Map.get("latest")
    |> Map.values()
    |> Enum.map(&%{key: &1, path: Path.join(path, &1)})
  end

  def s3_files_from_bucket(bucket, prefix) do
    ExAws.S3.list_objects(bucket, prefix: prefix)
    |> ExAws.request!()
    |> get_in([:body, :contents])
    |> Enum.reject(&is_s3_folder?/1)
  end

  defp put_file(file, bucket, prefix) do
    if !exists_on_s3?(file, bucket, prefix) do
      Logger.info("Uploading #{file.key}")
      key = Path.join(prefix, file.key)
      data = File.read!(file.path)
      headers = object_headers(file.path)
      ExAws.request!(ExAws.S3.put_object(bucket, key, data, headers))
    end
  end

  def object_headers(path) do
    [
      content_type: from_path(path),
      cache_control: "max-age=31536000",
      meta: [
        {"surrogate-control", Application.get_env(:changelog, :cdn_cache_control_s3)},
        {"surrogate-key", "static"}
      ]
    ]
  end

  defp delete_file(bucket, file) do
    Logger.info("Deleting #{file.key}")
    ExAws.request(ExAws.S3.delete_object(bucket, file.key))
  end

  defp is_s3_folder?(%{size: "0"}), do: true
  defp is_s3_folder?(_object), do: false

  defp exists_on_s3?(file, bucket, prefix) when is_map(file),
    do: exists_on_s3?(file.key, bucket, prefix)

  defp exists_on_s3?(file, bucket, prefix) do
    key = Path.join(prefix, file)

    case ExAws.request(ExAws.S3.head_object(bucket, key)) do
      {:ok, %{status_code: 200}} -> true
      {:error, _} -> false
    end
  end
end
