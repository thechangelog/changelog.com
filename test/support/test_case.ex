defmodule Changelog.TestCase do
  @moduledoc """
  Functions in this module are imported in all test modules
  """
  def fixtures_path() do
    Path.dirname(__ENV__.file) <> "/../fixtures"
  end
end
