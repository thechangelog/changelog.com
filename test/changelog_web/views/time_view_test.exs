defmodule ChangelogWeb.TimeViewTest do
  use ChangelogWeb.ConnCase, async: true

  import ChangelogWeb.TimeView

  describe "closest_monday_to" do
    test "returns same day when Mon" do
      assert closest_monday_to(~D[2017-01-02]) == ~D[2017-01-02]
    end

    test "returns previous Mon when Tues, Wed, Thur" do
      assert closest_monday_to(~D[2017-01-03]) == ~D[2017-01-02]
      assert closest_monday_to(~D[2017-01-04]) == ~D[2017-01-02]
      assert closest_monday_to(~D[2017-01-05]) == ~D[2017-01-02]
    end

    test "returns next Mon when Fri, Sat, Sun" do
      assert closest_monday_to(~D[2017-01-01]) == ~D[2017-01-02]
    end
  end

  describe "duration" do
    test "when input is nil or 0" do
      assert duration(nil) == "00:00"
      assert duration(0) == "00:00"
    end

    test "when input is seconds" do
      assert duration(4) == "00:04"
      assert duration(54) == "00:54"
    end

    test "when input is minutes" do
      assert duration(90) == "01:30"
      assert duration(69) == "01:09"
      assert duration(2000) == "33:20"
    end

    test "when input is hours" do
      assert duration(3600) == "1:00:00"
      assert duration(3750) == "1:02:30"
      assert duration(4500) == "1:15:00"
      assert duration(8475) == "2:21:15"
    end
  end

  describe "rounded_minutes" do
    test "when input is nil or 0" do
      assert rounded_minutes(nil) == 0
      assert rounded_minutes(0) == 0
    end

    test "when input produces a float" do
      assert rounded_minutes(3601) == 60
    end

    test "when input produces an integer" do
      assert rounded_minutes(54_000) == 900
    end
  end

  describe "seconds" do
    test "when duration is nil or 0" do
      assert seconds(nil) == 0
      assert seconds("00:00") == 0
    end

    test "when duration is seconds" do
      assert seconds("01") == 1
      assert seconds("59") == 59
    end

    test "when duration is minutes and seconds" do
      assert seconds("39:43") == 2383
      assert seconds("101:02") == 6062
    end

    test "when duration is hour, minutes, and seconds" do
      assert seconds("01:35:10") == 5710
      assert seconds("10:00:00") == 36_000
    end

    test "when duration has fraction of a sentence" do
      assert seconds("59.17") == 59
      assert seconds("01:35:10.70") == 5711
    end
  end

  describe "ts" do
    test "when passed nil" do
      assert ts(nil) == ""
    end

    test "when passed a naive date time" do
      {:safe, html} = ts(~N[2017-07-19 00:29:57])
      assert html == "<span class='time' data-style='admin'>2017-07-19T00:29:57Z</span>"
    end

    test "when passed a naive date time and style" do
      {:safe, html} = ts(~N[2017-07-19 00:29:57], "fancy")
      assert html == "<span class='time' data-style='fancy'>2017-07-19T00:29:57Z</span>"
    end
  end

  describe "rfc3339" do
    test "when passed nil" do
      assert rfc3339(nil) == ""
    end

    test "when passed a valid date time" do
      datetime = Timex.to_datetime({{2018, 2, 26}, {19, 40, 00}}, "America/Chicago")

      assert rfc3339(datetime) == "2018-02-26T19:40:00-06:00"
    end
  end

  describe "rss" do
    test "when passed nil" do
      assert rss(nil) == ""
    end

    test "when passed a valid date time" do
      datetime = Timex.to_datetime({{2018, 2, 26}, {19, 40, 00}}, "America/Chicago")

      assert rss(datetime) == "Mon, 26 Feb 2018 19:40:00 -0600"
    end
  end
end
