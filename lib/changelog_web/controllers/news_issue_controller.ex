defmodule ChangelogWeb.NewsIssueController do
  use ChangelogWeb, :controller

  alias Changelog.NewsIssue

  plug RequireAdmin, "before preview" when action in [:preview]
  plug :put_layout, false

  def show(conn, %{"id" => slug}) do
    issue =
      NewsIssue.published
      |> Repo.get_by!(slug: slug)
      |> NewsIssue.preload_all()

    render(conn, :show, issue: issue)
  end

  def preview(conn, %{"id" => slug}) do
    issue =
      NewsIssue
      |> Repo.get_by!(slug: slug)
      |> NewsIssue.preload_all()

    render(conn, :show, issue: issue)
  end
end
