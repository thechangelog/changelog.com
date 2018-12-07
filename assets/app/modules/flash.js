import { u } from "umbrellajs";

export default class Flash {
  constructor(container) {
    this.container = u(container);
    this.attachUI();
    this.attachEvents();
    container.flash = this;
  }

  attachUI() {
    // no-op
  }

  attachEvents() {
    this.container.handle("click", ".js-flash-close", _ => { this.close(); });
  }

  close() {
    this.container.addClass("is-closing");
    setTimeout(_ => { this.remove(); }, 1000);
  }

  remove() {
    this.container.remove();
  }
}
