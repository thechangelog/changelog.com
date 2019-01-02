import "phoenix_html";
import "intersection-observer";
import Turbolinks from "turbolinks";
import { u, ajax } from "umbrellajs";
import autosize from "autosize";
import Cookies from "cookies-js";
import Prism from "prismjs";
import Comment from "modules/comment";
import OnsitePlayer from "modules/onsitePlayer";
import MiniPlayer from "modules/miniPlayer";
import LivePlayer from "modules/livePlayer";
import Overlay from "modules/overlay";
import ImageButton from "modules/imageButton";
import YouTubeButton from "modules/youTubeButton";
import Share from "modules/share";
import Slider from "modules/slider";
import Log from "modules/log";
import Tooltip from "modules/tooltip";
import Flash from "modules/flash";
import ts from "../shared/ts";
import gup from "../shared/gup";
import parseTime from "../shared/parseTime";
import lozad from "lozad";

window.u = u;
window.App = {
  lazy: lozad(".lazy"),
  live: new LivePlayer(".js-live"),
  overlay: new Overlay("#overlay"),
  player: new OnsitePlayer("#player"),
  slider: new Slider(".js-slider"),

  attachComments() {
    u(".js-comment").each(el => {
      if (el.comment === undefined) new Comment(el);
      el.comment.detectPermalink();
    });
  },

  attachFlash() {
    u(".js-flash").each(el => {
      if (el.flash === undefined) new Flash(el);
    });
  },

  attachMiniPlayers() {
    u(".js-mini-player").each(el => {
      if (el.player === undefined) new MiniPlayer(el);
    });
  },

  attachTooltips() {
    new Tooltip(".has-tooltip");
  },

  detachFlash() {
    u(".js-flash").each(el => { el.flash.remove(); });
  },

  formatTimes() {
    u("span.time").each(el => {
      let span = u(el);
      let anchor = span.parent("a");
      let date = new Date(span.text());
      let style = span.data("style");
      span.text(ts(date, style));
      (anchor || span).attr("title", ts(date, "timeFirst"));
      span.removeClass("time");
    });
  },

  isExternalLink(a) {
    let href = a.attr("href");
    return (a.attr("rel") == "external" || (href[0] != "/" && !href.match(location.hostname)));
  },

  deepLink(href) {
    let linkTime = parseTime(gup("t", (href || location.href), "#"));
    if (!linkTime) return false;

    if (this.player.isPlaying()) {
      this.player.scrubEnd(linkTime);
    } else {
      let playable = u("[data-play]");
      this.player.load(playable.attr("href"), playable.data("play"), _ => {
        this.player.scrubEnd(linkTime);
      });
    }

    return true;
  }
}

// Hide tooltips when clicking anywhere else
u(document).on("click", function(event) {
  const target = u(event.target);
  if ((!target.closest('.has-tooltip').length) && (!target.closest('.tooltip').length) && (!target.hasClass('has-tooltip'))) {
    u(".tooltip").removeClass("is-visible");
  }
});

u(document).handle("click", ".js-toggle-nav", function(event) {
  u("body").toggleClass("nav-open");

  setTimeout(() => {
    u("body").toggleClass("nav-animate", "");
  }, 50);
});

u(document).handle("click", ".js-toggle_element", function(event) {
  const href = u(event.target).attr("href");
  u(href).toggleClass("is-hidden");
});

u(document).handle("click", ".js-account-nav", function(event) {
  const content = u(".js-account-nav-content").html();
  App.overlay.html(content).show();
});

u(document).handle("click", ".podcast-summary-widget_toggle", function(event) {
  u(event.target).siblings(".podcast-summary-widget_menu").toggleClass("podcast-summary-widget_menu--is-open");
});

u(document).on("click", "[data-play]", function(event) {
  if (App.player.canPlay()) {
    event.preventDefault();

    let clicked = u(event.target).closest("a, button");
    let audioUrl = clicked.attr("href");
    let detailsUrl = clicked.data("play");

    if (App.player.currentlyLoaded == detailsUrl) {
      App.player.togglePlayPause();
    } else {
      App.player.pause();
      App.player.load(audioUrl, detailsUrl);
    }
  }
});

u(document).handle("click", "[data-image]", function(event) {
  new ImageButton(this);
});

u(document).handle("click", "[data-youtube]", function(event) {
  new YouTubeButton(this);
});

u(document).handle("click", "[data-share]", function(event) {
  new Share(App.overlay).load(u(this).data("share"));
});

// open share dialogs in their own window (order matters or next rule will apply)
u(document).handle("click", ".js-share-popup", function(event) {
  var h, href, left, shareWindow, top, w;
  href = u(event.target).attr("href");
  w = 600;
  h = 300;
  left = (screen.width / 2) - (w / 2);
  top = (screen.height / 2) - (h / 2);
  Log.track("Social", "share", href);
  shareWindow = window.open(href, "Changelog", `location=1,status=1,scrollbars=1,width=${w},height=${h},top=${top},left=${left}`);
  shareWindow.opener = null;
});

// track news impressions
const observer = new IntersectionObserver(function(entries) {
  entries.forEach(entry => {
    if (!entry.isIntersecting) return;
    let el = u(entry.target);
    let type = el.data("news-type");
    let id = el.data("news-id");
    let csrf = u("[property=csrf]").attr("content");
    ajax(`/${type}/impress`, {method: "POST", headers: {"x-csrf-token": csrf}, body: {"ids": id}});
    observer.unobserve(entry.target);
  });
});

// track news clicks
u(document).on("mousedown", "[data-news]", function(event) {
  let clicked = u(this);
  let type = clicked.closest("[data-news-type]").data("news-type");
  let id = clicked.closest("[data-news-id]").data("news-id");
  if (!id) return false;
  let trackedHref = `${location.origin}/${type}/${id}/visit`;
  event.currentTarget.href = trackedHref;
});

// open external links in new window when player is doing its thing
u(document).on("click", "a[href^=http]", function(event) {
  if (App.player.isActive()) {
    let clicked = u(this);

    if (App.isExternalLink(clicked)) {
      event.preventDefault();
      let newWindow = window.open(clicked.attr("href"), "_blank");
      newWindow.opener = null;
    }
  }
});

// hide subscribe CTA
u(document).handle("click", ".js-hide-subscribe-cta", function(event) {
  Cookies.set("hide_subscribe_cta", "true");
  u(".js-subscribe_cta").remove();
});

// hide subscribe banner
u(document).handle("click", ".js-hide-subscribe-banner", function(event) {
  Cookies.set("hide_subscribe_banner", "true");
  u(".js-subscribe_banner").remove();
});

// hijack audio deep links
u(document).on("click", "a[href^=\\#t]", function(event) {
  let href = u(event.target).attr("href");

  if (App.deepLink(href)) {
    event.preventDefault();
    history.replaceState({}, document.title, href);
  };
});

// submit forms with Turbolinks
u(document).on("submit", "form", function(event) {
  event.preventDefault();

  let form = u(this);
  let submits = form.find("input[type=submit]");
  let action = form.attr("action");
  let method = form.attr("method");
  let referrer = location.href;

  if (method == "get") {
    return Turbolinks.visit(`${action}?${form.serialize()}`);
  }

  let options = {
    method: method,
    body: new FormData(form.first()),
    headers: {"Turbolinks-Referrer": referrer}
  };

  if (form.data("ajax")) {
    options.headers["Accept"] = "application/javascript";
  }

  submits.each(el => { el.setAttribute("disabled", true); });

  let andThen = function(err, resp, req) {
    submits.each(el => { el.removeAttribute("disabled"); });

    if (req.getResponseHeader("content-type").match(/javascript/)) {
      eval(resp);
      u(document).trigger("ajax:load");
    } else {
      let snapshot = Turbolinks.Snapshot.wrap(resp);
      Turbolinks.controller.cache.put(referrer, snapshot);
      Turbolinks.visit(referrer, {action: "restore"});
    }
  }

  ajax(action, options, andThen);
});

window.onhashchange = function() {
  App.deepLink();
}

u(document).on("turbolinks:before-cache", function() {
  u("body").removeClass("nav-open");
  App.overlay.hide();
  App.detachFlash();
});

// on page load
u(document).on("turbolinks:load", function() {
  Prism.highlightAll();
  App.lazy.observe();
  App.player.attach();
  App.live.check();
  u(".js-track-news").each(el => { observer.observe(el) });
  autosize(document.querySelectorAll("textarea"));
  App.attachComments();
  App.attachFlash();
  App.attachMiniPlayers();
  App.attachTooltips();
  App.formatTimes();
  App.deepLink();
});

u(document).on("ajax:load", function() {
  App.attachComments();
  App.attachFlash();
  App.attachTooltips();
  App.formatTimes();
  App.lazy.observe();
  autosize(document.querySelectorAll("textarea"));
});

Turbolinks.start();
