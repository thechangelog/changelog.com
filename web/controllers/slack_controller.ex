defmodule Changelog.SlackController do
  use Changelog.Web, :controller

  alias Changelog.Slack.Response

  def gotime(conn, _params) do
    response = %Response{text: ":truck: Changelog is on the move! I should be up and running again real soon :pray:"}
    json(conn, response)
  end
end
