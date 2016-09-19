import Turbolinks from "turbolinks";
import Popper from "popper.js";
import { u } from "umbrellajs";
import Player from "components/player";

const player = new Player("#player");

u(document).handle("click", ".navigation-bar_menu-button", function(event) {
  u(".navigation-bar_tray").toggleClass("navigation-bar_tray--is-open");
});

u(document).handle("click", ".podcast-summary-widget_toggle", function(event) {
  u(event.target).siblings(".podcast-summary-widget_menu").toggleClass("podcast-summary-widget_menu--is-open");
});

u(document).handle("click", "[data-play]", function(event) {
  const toPlay = u(event.target).closest("a,button").data("play");
  player.load(toPlay);
});

u(document).on("turbolinks:load", function() {
  u(".podcast-menu_more-button").each(function(node, i) {
    const tooltip = u(node).siblings(".podcast-menu-tooltip").first();
    new Popper(node, tooltip, {placement: "bottom"});

    u(node).handle("click", function(event) {
      u(tooltip).toggleClass("tooltip--is-open");
    })
  });
});

Turbolinks.start();
