defmodule Changelog.TimeViewTest do
  use Changelog.ConnCase, async: true

  alias Changelog.TimeView

  test "duration when input is nil or 0" do
    assert TimeView.duration(nil) == "00:00"
    assert TimeView.duration(0) == "00:00"
  end

  test "duration when input is seconds" do
    assert TimeView.duration(4) == "00:04"
    assert TimeView.duration(54) == "00:54"
  end

  test "duration when input is minutes" do
    assert TimeView.duration(90) == "01:30"
    assert TimeView.duration(69) == "01:09"
    assert TimeView.duration(2000) == "33:20"
  end

  test "duration when input is hours" do
    assert TimeView.duration(3600) == "1:00:00"
    assert TimeView.duration(3750) == "1:02:30"
    assert TimeView.duration(4500) == "1:15:00"
    assert TimeView.duration(8475) == "2:21:15"
  end

  test "seconds when duration is nil or 0" do
    assert TimeView.seconds(nil) == 0
    assert TimeView.seconds("00:00") == 0
  end

  test "seconds when duration is seconds" do
    assert TimeView.seconds("01") == 1
    assert TimeView.seconds("59") == 59
  end

  test "seconds when duration is minutes and seconds" do
    assert TimeView.seconds("39:43") == 2383
    assert TimeView.seconds("101:02") == 6062
  end

  test "seconds when duration is hour, minutes, and seconds" do
    assert TimeView.seconds("01:35:10") == 5710
    assert TimeView.seconds("10:00:00") == 36000
  end

  test "seconds when duration has fraction of a sentence" do
    assert TimeView.seconds("59.17") == 59
    assert TimeView.seconds("01:35:10.70") == 5711
  end
end
