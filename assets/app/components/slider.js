import { u } from "umbrellajs";

export default class Slider {
  constructor(selector) {
    this.selector = selector;
    this.refreshContainer();
  }

  slide(offset) {
    this.refreshContainer();

    let currentActive;
    let nextActive;
    let newIndex;

    this.container.each(function(el, index) {
      let uEl = u(el);

      if (uEl.hasClass("is-active")) {
        newIndex = index + offset;
        currentActive = uEl;
      }
    });

    if (newIndex < 0) { // walked off front; go to back
      newIndex = this.lastIndex();
    }

    if (newIndex > this.lastIndex()) { // walked off back; go to front
      newIndex = 0;
    }

    nextActive = u(this.container.nodes[newIndex]);

    currentActive.removeClass("is-active");
    nextActive.addClass("is-active");
  }

  refreshContainer() {
    this.container = u(this.selector);
  }

  lastIndex() {
    return this.container.nodes.length - 1;
  }
}
