import { u } from "umbrellajs";

export default class Overlay {
  constructor(selector) {
    this.container = u(selector);
    this.closeButton = this.container.find(".js-overlay-close");
    this.content = this.container.find(".js-overlay-content");
    this.closeButton.handle("click", () => { this.hide(); });
  }

  html(newHtml) {
    this.content.html(newHtml);
    return this;
  }

  find(selector) {
    return this.container.find(selector);
  }

  show() {
    this.container.addClass("is-visible");
    return this;
  }

  hide() {
    this.html("");
    this.container.removeClass("is-visible");
    return this;
  }
}
