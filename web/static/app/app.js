import Popper from "popper.js";
import { u } from "umbrellajs";
import Player from "components/player";

const player = new Player("#player");

u(".navigation-bar_menu-button").handle("click", function(event) {
  u(".navigation-bar_tray").toggleClass("navigation-bar_tray--is-open");
});

u(".podcast-summary-widget_toggle").handle("click", function(event) {
  u(this).siblings(".podcast-summary-widget_menu").toggleClass("podcast-summary-widget_menu--is-open");
});

u(".podcast-menu_more-button").each(function(node, i) {
  const tooltip = u(node).siblings(".podcast-menu-tooltip").first();
  new Popper(node, tooltip, {placement: "bottom"});

  u(node).handle("click", function(event) {
    u(tooltip).toggleClass("tooltip--is-open");
  })
});

u("body").handle("click", "[data-play]", function(event) {
  const toPlay = u(event.target).closest("a,button").data("play");
  player.load(toPlay);
});
