import Popper from "popper.js";
import { u } from "umbrellajs";

export default class Tooltip {
  constructor(container) {
    this.container = u(container);
    this.attachUI();
    this.attachEvents();
    container.tooltip = this;
  }

  attachUI() {
    let el = this.container.first();
    let tooltipEl = this.container.siblings(".tooltip").first();
    let placement = u(tooltipEl).data("placement") || "bottom";
    this.popper = new Popper(el, tooltipEl, {placement: placement});
  }

  attachEvents() {
    this.container.handle("click", () => {
      let siblingTooltip = this.container.siblings(".tooltip");
      u(".tooltip").not(siblingTooltip).removeClass("is-visible");
      this.container.siblings(".tooltip").toggleClass("is-visible");
      this.popper.update();
    });
  }
}
