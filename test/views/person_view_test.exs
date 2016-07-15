defmodule Changelog.PersonViewTest do
  use Changelog.ConnCase, async: true

  import Changelog.PersonView

  test "external_url" do
    assert external_url(build(:person)) == "#"
    assert external_url(build(:person, website: "test.com")) == "test.com"
    assert external_url(build(:person, twitter_handle: "handle")) == "https://twitter.com/handle"
    assert external_url(build(:person, github_handle: "handle")) == "https://github.com/handle"
  end

  test "comma_separated_names" do
    p1 = build(:person, name: "The Gangsta")
    p2 = build(:person, name: "The Killa")
    p3 = build(:person, name: "The Dope Dealer")
    p4 = build(:person, name: "You")

    assert comma_separated_names(nil) == ""
    assert comma_separated_names([]) == ""
    assert comma_separated_names([p1]) == "The Gangsta"
    assert comma_separated_names([p1, p2]) == "The Gangsta and The Killa"
    assert comma_separated_names([p1, p2, p3]) == "The Gangsta, The Killa, and The Dope Dealer"
    assert comma_separated_names([p1, p2, p3, p4]) == "The Gangsta, The Killa, The Dope Dealer, and You"
  end
end
