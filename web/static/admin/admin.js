import "phoenix_html";
import autosize from "autosize";
import benefitView from "views/benefitView";
import channelView from "views/channelView";
import episodeView from "views/episodeView";
import podcastView from "views/podcastView";
import postView from "views/postView";
import ts from "../shared/ts";

let views = {
  "BenefitView": benefitView,
  "ChannelView": channelView,
  "PodcastView": podcastView,
  "EpisodeView": episodeView,
  "PostView": postView
};

autosize($("textarea:not(.scroll)"));

$("a[rel=external]").attr("target", "_blank");
$("input[readonly]").popup({
  content: "Read-only because danger. Use the console if you really need to edit this.",
  variation: "very wide"
});
$(".ui.dropdown").dropdown();
$(".ui.checkbox").checkbox();
$(".ui.button, [data-popup=true]").popup();
$(".ui.modal").modal();

$(".js-modal").on("click", function() {
  const modalSelector = $(this).data("modal");
  $(modalSelector).modal("show");
});

$("span.time").each(function() {
  const $span = $(this);
  let date = new Date($span.text());
  let style = $span.data("style");
  $span.text(ts(date, style));
});

$(".ui.navigation.search").search({
  type: "category",
  minCharacters: 3,
  apiSettings: {
    url: "/admin/search?q={query}&f=json"
  },
  onSelect: function(result, response) {
    console.log("FAIL", result["url"]);
    return false;
  }
});

let $body = $("body");
let viewName = $body.data("module").match(/\.(\w+View)$/)[1];
let actionName = $body.data("template").replace(".html", "");

let viewClass = views[viewName];

if (viewClass !== undefined) {
  let activeView = new viewClass();

  if ($.isFunction(activeView.shared))
    activeController.shared();

  if ($.isFunction(activeView[actionName]))
    activeView[actionName]();
}
