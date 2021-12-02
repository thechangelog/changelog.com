defmodule Mix.Tasks.Changelog.Static.Upload.Clean do
  use Mix.Task

  @shortdoc "Deletes stale static files from S3"

  def run(_) do
    Mix.Task.run("app.start")
    Changelog.S3Static.delete_unused_files_from_s3()
  end
end
