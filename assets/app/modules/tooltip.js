import Popper from "popper.js";
import { u } from "umbrellajs";

export default class Tooltip {
  constructor(selector) {
    this.tooltipParents = u(selector);
    this.tooltipSelector = ".tooltip";

    if (this.tooltipParents.length) {
      this.attach(this.tooltipParents);
    }
  }

  attach(parents) {
    parents.each(function attachTooltip(el) {
      let tooltipElement = u(el).siblings(".tooltip").first();
      let placement = u(tooltipElement).data("placement");

      if (!placement) {
        placement = "bottom";
      }

      let tooltip = new Popper(el, tooltipElement, {
        placement: placement,
      });

      u(el).on("click", () => {
        const siblingTooltip = u(el).siblings(".tooltip");
        u(".tooltip").not(siblingTooltip).removeClass("is-visible");
        u(el).siblings(".tooltip").toggleClass("is-visible");
        tooltip.update();
      });
    });
  }
}
