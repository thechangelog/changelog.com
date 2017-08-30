import assert from "assert";
import gup from "../shared/gup";

describe("gup", function() {
  it("works with query strings by default", function() {
    assert.equal("ohai", gup("x", "http://example.com/?x=ohai"));
    assert.equal("woof", gup("doge", "/test?x=ohai&doge=woof"));
  });

  it("works with query fragments when passed delimiter", function() {
    assert.equal("ohai", gup("x", "http://example.com/#x=ohai", "#"));
    assert.equal("woof", gup("doge", "/test#x=ohai&doge=woof", "#"));
  });
});
