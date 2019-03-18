import assert from "assert";
import Time from "../shared/time";

function timeFor(string) {
  return new Time(new Date(string));
}

let oneMinute = 60000; // milliseconds

describe("amPm", function() {
  it("returns AM in the AM", function() {
    let time = timeFor("July 12, 1982 11:59:59");
    assert.equal(time.amPm(), "AM");
  });

  it("returns PM in the PM", function() {
    let time = timeFor("July 12, 1982 12:00:00");
    assert.equal(time.amPm(), "PM");
  });
});

describe("relativeLongStyle", function() {
  it("works for minutes", function() {
    let time = timeFor(Date.now() - (30 * oneMinute));
    assert.equal(time.relativeLongStyle(), "30 minutes ago");
  });

  it("works for hours", function() {
    let time = timeFor(Date.now() - (90 * oneMinute));
    assert.equal(time.relativeLongStyle(), "2 hours ago");
  });

  it("works for days", function() {
    let time = timeFor(Date.now() - (25 * 60 * oneMinute));
    assert.equal(time.relativeLongStyle(), "1 day ago");
  });

  it("works for weeks", function() {
    let time = timeFor(Date.now() - (14 * 24 * 60 * oneMinute));
    assert.equal(time.relativeLongStyle(), "2 weeks ago");
  });

  it("works for months", function() {
    let time = timeFor(Date.now() - (31 * 24 * 60 * oneMinute));
    assert.equal(time.relativeLongStyle(), "1 month ago");
  });

  it("works for years", function() {
    let time = timeFor(Date.now() - (12 * 31 * 24 * 60 * oneMinute));
    assert.equal(time.relativeLongStyle(), "1 year ago");
  });
})

describe("relativeShortStyle", function() {
  it("works for minutes", function() {
    let time = timeFor(Date.now() - (30 * oneMinute));
    assert.equal(time.relativeShortStyle(), "30m");
  });

  it("works for hours", function() {
    let time = timeFor(Date.now() - (90 * oneMinute));
    assert.equal(time.relativeShortStyle(), "2h");
  });

  it("works for days", function() {
    let time = timeFor(Date.now() - (25 * 60 * oneMinute));
    assert.equal(time.relativeShortStyle(), "1d");
  });

  it("works for weeks", function() {
    let time = timeFor(Date.now() - (14 * 24 * 60 * oneMinute));
    assert.equal(time.relativeShortStyle(), "2wk");
  });

  it("works for months", function() {
    let time = timeFor(Date.now() - (31 * 24 * 60 * oneMinute));
    assert.equal(time.relativeShortStyle(), "1mo");
  });

  it("works for years", function() {
    let time = timeFor(Date.now() - (12 * 31 * 24 * 60 * oneMinute));
    assert.equal(time.relativeShortStyle(), "1yr");
  });
})
