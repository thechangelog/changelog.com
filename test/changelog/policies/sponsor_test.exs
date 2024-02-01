defmodule Changelog.Policies.SponsorTest do
  use Changelog.PolicyCase

  # import Mock

  alias Changelog.Policies.Sponsor

  test "only admins and sponsor reps can show" do
    assert Sponsor.show(@admin, %{})
    assert Sponsor.show(@user, %{reps: [@user]})
    refute Sponsor.show(@host, %{reps: [@user]})
  end
end
