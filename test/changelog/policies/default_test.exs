defmodule Changelog.Policies.DefaultTest do
  use Changelog.PolicyCase

  defmodule TestPolicy, do: use Changelog.Policies.Default

  test "nobody can new/create" do
    for actor <- @all do
      refute TestPolicy.create(actor)
    end
  end

  test "nobody can index" do
    for actor <- @all do
      refute TestPolicy.index(actor)
    end
  end

  test "nobody can show" do
    for actor <- @all do
      refute TestPolicy.show(actor, %{})
    end
  end

  test "nobody can edit/update" do
    for actor <- @all do
      refute TestPolicy.edit(actor, %{})
    end
  end

  test "nobody can delete" do
    for actor <- @all do
      refute TestPolicy.delete(actor, %{})
    end
  end
end
