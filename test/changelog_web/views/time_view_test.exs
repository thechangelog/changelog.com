defmodule ChangelogWeb.TimeViewTest do
  use ChangelogWeb.ConnCase, async: true

  import ChangelogWeb.TimeView

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
      assert rounded_minutes(54000) == 900
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
      assert seconds("10:00:00") == 36000
    end

    test "when duration has fraction of a sentence" do
      assert seconds("59.17") == 59
      assert seconds("01:35:10.70") == 5711
    end
  end
end
