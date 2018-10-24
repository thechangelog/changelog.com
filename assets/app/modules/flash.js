import { u } from "umbrellajs";

export default class Flash {
  constructor(selector) {
    this.selector = selector;
  }

  attach() {
    this.container = u(this.selector);
    this.container.handle("click", ".js-flash-close", _ => { this.close(); });
    this.tid = setTimeout(_ => { this.close(); }, 10*1000);
  }

  detach() {
    clearTimeout(this.tid);
    this.container.children().remove();
    this.container = null;
  }

  close() {
    this.container.addClass("is-closing");
    setTimeout(_ => { this.container.remove(); }, 1000);
  }
}
