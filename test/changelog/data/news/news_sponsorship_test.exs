defmodule Changelog.NewsSponsorshipTest do
  use Changelog.DataCase

  alias Changelog.{NewsSponsorship}

  describe "ad_for_issue" do
    test "finds the ad marked 'newsletter'" do
      sponsorship = insert(:news_sponsorship)
      insert(:news_ad, sponsorship: sponsorship, newsletter: false)
      insert(:news_ad, sponsorship: sponsorship, newsletter: false)
      found = insert(:news_ad, sponsorship: sponsorship, newsletter: true)
      assert NewsSponsorship.ad_for_issue(sponsorship).id == found.id
    end

    test "or finds an ad that hasn't been in an issue yet" do
      sponsorship = insert(:news_sponsorship)
      ad1 = insert(:news_ad, sponsorship: sponsorship)
      insert(:news_issue_ad, ad: ad1)
      ad2 = insert(:news_ad, sponsorship: sponsorship)
      insert(:news_issue_ad, ad: ad2)
      found = insert(:news_ad, sponsorship: sponsorship)
      assert NewsSponsorship.ad_for_issue(sponsorship).id == found.id
    end

    test "or finds a random ad" do
      sponsorship = insert(:news_sponsorship)
      ad1 = insert(:news_ad, sponsorship: sponsorship)
      ad2 = insert(:news_ad, sponsorship: sponsorship)
      found = NewsSponsorship.ad_for_issue(sponsorship)
      assert Enum.any?([ad1.id, ad2.id], fn(x) -> x == found.id end)
    end

    test "or returns nil if no ads" do
      sponsorship = insert(:news_sponsorship)
      assert is_nil(NewsSponsorship.ad_for_issue(sponsorship))
    end
  end
end
