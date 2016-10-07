import Turbolinks from "turbolinks";
import Popper from "popper.js";
import { u } from "umbrellajs";
import Player from "components/player";
import Slider from "components/slider";

const player = new Player("#player");
const featured = new Slider(".featured_podcast");

u(document).handle("click", ".js-toggle-nav", function(event) {
  u("body").toggleClass("nav-open");
});

u(document).handle("click", ".podcast-summary-widget_toggle", function(event) {
  u(event.target).siblings(".podcast-summary-widget_menu").toggleClass("podcast-summary-widget_menu--is-open");
});

u(document).handle("click", "[data-play]", function(event) {
  const clicked = u(event.target).closest("a, button");
  player.load(clicked.attr("href"), clicked.data("play"));
});

// open external links in new window when player is doing its thing
u(document).on("click", "a[href^=http]", function(event) {
  if (player.isPlaying()) {
    let href = u(this).attr("href");
    if (!href.match(window.location.hostname)) {
      event.preventDefault();
      window.open(href, "_blank");
    }
  }
});

u(document).handle("click", ".js-featured-next", function(event) {
  featured.slide(+1);
});

u(document).handle("click", ".js-featured-previous", function(event) {
  featured.slide(-1);
});

// Open a URL in a popup window (for Facebook sharing, etc.)
u(document).handle("click", ".js-share-popup", function(event) {
  var h, href, left, shareWindow, top, w;
  href = u(event.target).attr("href");
  w = 600;
  h = 300;
  left = (screen.width / 2) - (w / 2);
  top = (screen.height / 2) - (h / 2);
  shareWindow = window.open(href, "Changelog", "location=1,status=1,scrollbars=1, width=" + w + ",height=" + h + ",top=" + top + ",left=" + left);
});

// Make sure all slider slides are the same height
function tallestSlide() {
  let tallestFeatured = 0;
  // 1. Set height of .featured to "auto"
  u(".featured").attr("height", "auto");

  // 2. Find the tallest instance of .featured_podcast
  u(".featured_podcast_wrap").each(function(el) {
    let featuredHeight = u(el).size().height;
    if (featuredHeight > tallestFeatured) {
      tallestFeatured = featuredHeight;
    }
  });

  // 3. Set height of all .featured_podcast and .featured to value found in step 2
  u(".featured").attr("style", "height: " + tallestFeatured + "px;");
}

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

  tallestSlide();
});

// On Resize
window.onresize = function() {
  tallestSlide();
}

Turbolinks.start();
