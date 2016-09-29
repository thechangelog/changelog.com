import Turbolinks from "turbolinks";
import Popper from "popper.js";
import { u } from "umbrellajs";
import Player from "components/player";
import Slider from "components/slider";

const player = new Player("#player");
const featured = new Slider(".featured_podcast");

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

u(document).handle("click", ".js-featured-next", function(event) {
  featured.slide(+1);
});

u(document).handle("click", ".js-featured-previous", function(event) {
  featured.slide(-1);
});

// On Page Load
u(document).on("turbolinks:load", function() {
  u(".podcast-menu_more-button").each(function(node, i) {
    const tooltip = u(node).siblings(".podcast-menu-tooltip").first();
    new Popper(node, tooltip, {
      placement: "right",
      boundariesElement: u("body"),
      arrowClassNames: "tooltip__arrow"
    });

    u(node).handle("click", function(event) {
      u(tooltip).toggleClass("tooltip--is-open");
    });
  });
  // On Resize
  // 1. Set height of all .featured_podcast and .featured to "auto"
  // 2. Find the tallest instance of .featured_podcast
  // 3. Set height of all .featured_podcast and .featured to value found in step 2
});

Turbolinks.start();
