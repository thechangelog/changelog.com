import assert from "assert";
import Time from "../shared/time";

function timeFor(string) {
  return new Time(new Date(string));
}

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
