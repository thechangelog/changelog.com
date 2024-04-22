defmodule Changelog.EpisodeGuestTest do
  use Changelog.SchemaCase

  import Mock

  alias Changelog.{EpisodeGuest, Merch}

  describe "changeset" do
    test "valid attributes" do
      changeset = EpisodeGuest.changeset(%EpisodeGuest{}, %{position: 42})
      assert changeset.valid?
    end

    test "invalid attributes" do
      changeset = EpisodeGuest.changeset(%EpisodeGuest{}, %{})
      refute changeset.valid?
    end
  end

  describe "thanks/1" do
    test "generates and saves a discount code for later use" do
      with_mock(Merch, create_discount: fn _, _ -> {:ok, %{code: "hai"}} end) do
        podcast = insert(:podcast, slug: "news")
        episode = insert(:episode, podcast: podcast)
        eg = insert(:episode_guest, episode: episode)
        {:ok, eg} = EpisodeGuest.thanks(eg)
        assert eg.thanks
        assert eg.discount_code == "hai"
        assert called(Changelog.Merch.create_discount(:_, :_))
      end
    end

    test "doesn't generate a duplicate discount code when already present" do
      with_mock(Merch, create_discount: fn _, _ -> {:ok, %{code: "hai"}} end) do
        eg = insert(:episode_guest, discount_code: "yup")
        {:ok, eg} = EpisodeGuest.thanks(eg)
        assert eg.thanks
        assert eg.discount_code == "yup"
        refute called(Changelog.Merch.create_discount(:_, :_))
      end
    end
  end
end
