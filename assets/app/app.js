import "phoenix_html";
import { u, ajax } from "umbrellajs";
import autosize from "autosize";
import Cookies from "cookies-js";
import Prism from "prismjs";
import Comment from "modules/comment";
import OnsitePlayer from "modules/onsitePlayer";
import MiniPlayer from "modules/miniPlayer";
import Overlay from "modules/overlay";
import ImageButton from "modules/imageButton";
import YouTubeButton from "modules/youTubeButton";
import Share from "modules/share";
import Slider from "modules/slider";
import Log from "modules/log";
import Ten from "modules/ten";
import Tooltip from "modules/tooltip";
import Flash from "modules/flash";
import ts from "../shared/ts";
import gup from "../shared/gup";
import parseTime from "../shared/parseTime";

window.u = u;
window.App = {
  overlay: new Overlay("#overlay"),
  player: new OnsitePlayer("#player"),
  slider: new Slider(".js-slider"),
  ten: new Ten(),

  attachComments() {
    u(".js-comment").each((el) => {
      if (el.comment === undefined) new Comment(el);
      el.comment.detectPermalink();
    });
  },

  attachFlash() {
    u(".js-flash").each((el) => {
      if (el.flash === undefined) new Flash(el);
    });
  },

  attachMiniPlayers() {
    u(".js-mini-player").each((el) => {
      if (el.player === undefined) new MiniPlayer(el);
    });
  },

  attachTooltips() {
    u(".has-tooltip").each((el) => {
      if (el.tooltip === undefined) new Tooltip(el);
    });
  },

  detachFlash() {
    u(".js-flash").each((el) => {
      el.flash.remove();
    });
  },

  deepLink(href) {
    let linkTime = parseTime(gup("t", href || location.href, "#"));
    if (!linkTime) return false;

    if (this.player.isPlaying()) {
      this.player.scrubEnd(linkTime);
    } else {
      let playable = u("[data-play]");
      this.player.load(playable.data("play"), (_) => {
        this.player.scrubEnd(linkTime);
        this.player.play();
        this.player.log("Play");
      });
    }

    return true;
  },

  formatTimes() {
    u("span.time").each((el) => {
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
    return (
      a.attr("rel") == "external" ||
      (href[0] != "/" && !href.match(location.hostname))
    );
  }
};

// Hide tooltips when clicking anywhere else
u(document).on("click", function (event) {
  const target = u(event.target);
  if (
    !target.closest(".has-tooltip").length &&
    !target.closest(".tooltip").length &&
    !target.hasClass("has-tooltip")
  ) {
    u(".tooltip").removeClass("is-visible");
  }
});

u(document).handle("click", ".js-toggle-nav", function (event) {
  u("body").toggleClass("nav-open");

  setTimeout(() => {
    u("body").toggleClass("nav-animate", "");
  }, 50);
});

// Toggle podcast subscriptions via ajax
u(document).on("change", ".js-toggle-subscription", function (event) {
  let checkBox = u(event.target);
  let slug = checkBox.data("slug");
  let action = checkBox.is(":checked") ? "subscribe" : "unsubscribe";
  ajax(`~/${action}`, { method: "POST", body: { slug: slug } });
});

u(document).handle("click", ".js-subscribe-all", function (event) {
  u(event.target).remove();
  u(".js-toggle-subscription:not(:checked)").each((el) => {
    el.click();
  });
});

// Manage custom feed podcasts
u(document).on("click", ".js-feed-podcast_ids button", function (event) {
  event.preventDefault();
  let podcast = u(event.target).closest("button");
  let id = podcast.data("id");

  if (podcast.hasClass("disabled")) {
    podcast.removeClass("disabled");
    podcast.append(
      `<input type="hidden" name="feed[podcast_ids][]" value="${id}">`
    );
  } else {
    podcast.addClass("disabled");
    podcast.find("input").remove();
  }
});

// Manage custom feed covers
u(document).on("change", ".js-feed-cover_select", function (event) {
  let coverUrl = event.target.value;

  u(".js-feed-cover_field").find("img").attr("src", coverUrl);
  u(".js-feed-cover_field").find("input[type=hidden]").first().value = coverUrl;
});

u(document).on(
  "change",
  ".js-feed-cover_field input[type=file]",
  function (event) {
    let file = event.target.files[0];

    if (file) {
      let reader = new FileReader();
      reader.onload = function (e) {
        u(".js-feed-cover_field").find("img").attr("src", e.target.result);
      };
      reader.readAsDataURL(file);
    }
  }
);

u(document).handle("click", ".js-toggle_element", function (event) {
  const href = u(event.target).attr("href");
  u(href).toggleClass("is-hidden");
});

u(document).handle("click", ".podcast-summary-widget_toggle", function (event) {
  u(event.target)
    .siblings(".podcast-summary-widget_menu")
    .toggleClass("podcast-summary-widget_menu--is-open");
});

u(document).on("click", "[data-play]", function (event) {
  if (App.player.canPlay()) {
    event.preventDefault();

    let clicked = u(event.target).closest("a, button");
    let detailsUrl = clicked.data("play");
    let linkTime = parseTime(clicked.data("t"));

    if (App.player.isLoaded(detailsUrl)) {
      App.player.togglePlayPause();
    } else {
      App.player.pause();
      App.player.load(detailsUrl, (_) => {
        App.player.play();
        App.player.log("Play");
        if (linkTime) App.player.scrubEnd(linkTime);
      });
    }
  }
});

u(document).handle("click", "[data-image]", function (event) {
  new ImageButton(this);
});

u(document).handle("click", "[data-youtube]", function (event) {
  new YouTubeButton(this);
});

u(document).handle("click", "[data-share]", function (event) {
  new Share(App.overlay).load(u(this).data("share"));
});

u(document).handle("click", "[data-copy]", function (event) {
  const el = u(event.target);
  const type = "text/plain";
  const blob = new Blob([el.data("copy")], { type });
  const data = [new ClipboardItem({ [type]: blob })];

  navigator.clipboard.write(data).then(() => {
    let preText = el.text();
    let successText = el.data("copy-text") || "Copied!";
    el.text(successText);
    setTimeout(() => {
      el.text(preText);
    }, 1200);
  });
});

// open share dialogs in their own window (order matters or next rule will apply)
u(document).handle("click", ".js-share-popup", function (event) {
  var h, href, left, shareWindow, top, w;
  href = u(event.target).attr("href");
  w = 600;
  h = 500;
  left = screen.width / 2 - w / 2;
  top = screen.height / 2 - h / 2;
  Log.track("Social", { action: "share", url: href });
  shareWindow = window.open(
    href,
    "Changelog",
    `location=1,status=1,scrollbars=1,width=${w},height=${h},top=${top},left=${left}`
  );
  shareWindow.opener = null;
});

// open external links in new window when player is doing its thing
u(document).on("click", "a[href^=http]", function (event) {
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
u(document).handle("click", ".js-hide-subscribe-cta", function (event) {
  Cookies.set("hide_subscribe_cta", "true");
  u(".js-subscribe_cta").remove();
});

// hide subscribe banner
u(document).handle("click", ".js-hide-subscribe-banner", function (event) {
  Cookies.set("hide_subscribe_banner", "true");
  u(".js-subscribe_banner").remove();
});

// hijack audio deep links
u(document).on("click", "a[href^=\\#t]", function (event) {
  let href = u(event.target).attr("href");

  if (App.deepLink(href)) {
    event.preventDefault();
    history.replaceState({}, document.title, href);
  }
});

window.onhashchange = function () {
  App.deepLink();
};

u(document).on("DOMContentLoaded", function () {
  Prism.highlightAll();
  App.player.attach();
  autosize(document.querySelectorAll("textarea"));
  App.attachComments();
  App.attachFlash();
  App.attachMiniPlayers();
  App.attachTooltips();
  App.formatTimes();
  App.deepLink();
});

u(document).on("ajax:load", function () {
  App.attachComments();
  App.attachFlash();
  App.attachTooltips();
  App.formatTimes();
  autosize(document.querySelectorAll("textarea"));
});
