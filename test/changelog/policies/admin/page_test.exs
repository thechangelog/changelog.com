defmodule Changelog.Policies.Admin.PageTest do
  use Changelog.PolicyCase

  alias Changelog.Policies.Admin.Page

  test "only admins, editors, and hosts can index" do
    refute Page.index(@guest)
    refute Page.index(@user)
    assert Page.index(@admin)
    assert Page.index(@editor)
    assert Page.index(@host)
  end

  test "only admins can purge" do
    refute Page.purge(@editor)
    refute Page.purge(@host)
    assert Page.purge(@admin)
  end
end
