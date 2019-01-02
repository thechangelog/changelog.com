import "phoenix_html";

import benefitView from "views/benefitView";
import episodeView from "views/episodeView";
import newsIssueView from "views/newsIssueView";
import newsItemView from "views/newsItemView";
import newsItemCommentView from "views/newsItemCommentView";
import newsSponsorshipView from "views/newsSponsorshipView";
import podcastView from "views/podcastView";
import postView from "views/postView";
import topicView from "views/topicView";
import ts from "../shared/ts";
import FormUI from "components/formUI";

let views = {
  "BenefitView": benefitView,
  "TopicView": topicView,
  "EpisodeView": episodeView,
  "NewsItemView": newsItemView,
  "NewsItemCommentView": newsItemCommentView,
  "NewsIssueView": newsIssueView,
  "NewsSponsorshipView": newsSponsorshipView,
  "PodcastView": podcastView,
  "PostView": postView
};

FormUI.init();

$("a[rel=external]").attr("target", "_blank");
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
  $span.attr("title", ts(date, "timeFirst"));
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
