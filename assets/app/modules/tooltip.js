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
      const tooltipElement = u(el).siblings(".tooltip").first();
      let placement = u(tooltipElement).data("placement");

      if (placement === "") {
        placement = "bottom";
      }

      const tooltip = new Popper(el, tooltipElement, {
        placement: placement,
      });

      u(el).on("click", () => {
        u(el).siblings(".tooltip").toggleClass("is-visible");
        tooltip.scheduleUpdate();
      });
    });
  }
}
