defmodule Changelog.PageController do
  use Changelog.Web, :controller

  # simply render the template that matches the page/action name
  def action(conn, _params) do
    render(conn, action_name(conn))
  end
end
