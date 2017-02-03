import Turbolinks from "turbolinks";
import { u, ajax } from "umbrellajs";
import OnsitePlayer from "components/onsite_player";
import Slider from "components/slider";
import Overlay from "components/overlay";
import Share from "components/share";
import Log from "components/log";

const player = new OnsitePlayer("#player");
const overlay = new Overlay("#overlay");
const featured = new Slider(".featured_podcast");

u(document).handle("click", ".js-toggle-nav", function(event) {
  u("body").toggleClass("nav-open");
});

u(document).handle("click", ".js-account-nav", function(event) {
  const content = u(".js-account-nav-content").html();
  overlay.html(content).show();
});

u(document).handle("click", ".podcast-summary-widget_toggle", function(event) {
  u(event.target).siblings(".podcast-summary-widget_menu").toggleClass("podcast-summary-widget_menu--is-open");
});

u(document).on("click", "[data-play]", function(event) {
  if (player.canPlay()) {
    event.preventDefault();
    const clicked = u(event.target).closest("a, button");
    player.load(clicked.attr("href"), clicked.data("play"));
  }
});

u(document).handle("click", "[data-share]", function(event) {
  new Share(overlay).load(u(this).data("share"));
});

// open share dialogs in their own window (order matters or next rule will apply)
u(document).handle("click", ".js-share-popup", function(event) {
  Log.track("Share");
  var h, href, left, shareWindow, top, w;
  href = u(event.target).attr("href");
  w = 600;
  h = 300;
  left = (screen.width / 2) - (w / 2);
  top = (screen.height / 2) - (h / 2);
  shareWindow = window.open(href, "Changelog", `location=1,status=1,scrollbars=1,width=${w},height=${h},top=${top},left=${left}`);
  shareWindow.opener = null;
});

// open external links in new window when player is doing its thing
u(document).on("click", "a[href^=http]", function(event) {
  if (player.isActive()) {
    let href = u(this).attr("href");
    if (!href.match(window.location.hostname)) {
      event.preventDefault();
      let newWindow = window.open(href, "_blank");
      newWindow.opener = null;
    }
  }
});

// our own little phoenix_html
u(document).handle("click", "a[data-submit=parent]", function(event) {
  u(event.target.parentNode).trigger("submit");
});

// submit Campain Monitor forms via jsonp
u(document).on("submit", "form.js-cm", function(event) {
  event.preventDefault();

  const form = u(this);
  const status = form.find(".form_submit_responses");

  status.html("<div class='form_submit_response'>Sending...</div>");

  window.afterSubscribe = function(data) {
    if (data.Status == 200) {
      Turbolinks.visit(data.RedirectUrl);
    } else {
      status.html(`<div class="form_submit_response form_submit_response--error">${data.Message}</div>`);
    }
  }

  const script = document.createElement("script");
  script.src = form.attr("action") + "?callback=afterSubscribe&" + form.serialize();
  document.body.appendChild(script);
});

// submit all other forms with Turbolinks
u(document).on("submit", "form:not(.js-cm)", function(event) {
  event.preventDefault();

  const form = u(this);
  const action = form.attr("action");
  const method = form.attr("method");
  const data = form.serialize();
  const referrer = window.location.href;

  if (method == "get") {
    return Turbolinks.visit(`${action}?${data}`);
  }

  const options = {method: method, body: data, headers: {"Turbolinks-Referrer": referrer}};
  const andThen = function(err, resp, req) {
    if (req.getResponseHeader("content-type").match(/javascript/)) {
      eval(resp);
    } else {
      const snapshot = Turbolinks.Snapshot.wrap(resp);
      Turbolinks.controller.cache.put(referrer, snapshot);
      Turbolinks.visit(referrer, {action: "restore"});
    }
  }

  ajax(action, options, andThen);
});

// handle featured sliders
u(document).handle("click", ".js-featured-next", function(event) { featured.slide(+1); });
u(document).handle("click", ".js-featured-previous", function(event) { featured.slide(-1); });

// ensure all slider slides are the same height
function tallestSlide() {
  let tallestFeatured = 0;
  u(".featured").attr("height", "auto");

  u(".featured_podcast_wrap").each(function(el) {
    let featuredHeight = u(el).size().height;
    if (featuredHeight > tallestFeatured) {
      tallestFeatured = featuredHeight;
    }
  });

  u(".featured").attr("style", "height: " + tallestFeatured + "px;");
}

window.onresize = function() {
  tallestSlide();
}

// on page load
u(document).on("turbolinks:load", function() {
  u("body").removeClass("nav-open");
  overlay.hide();
  tallestSlide();
});

// Make sure homepage featured section is the correct size (after fonts and images load)
window.setTimeout(function() {
  tallestSlide();
}, 500);

Turbolinks.start();
