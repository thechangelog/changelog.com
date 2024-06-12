import "phoenix_html";
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import "regenerator-runtime/runtime";

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken }
});

// Connect if there are any LiveViews on the page
liveSocket.connect();

import episodeView from "views/episodeView";
import feedView from "views/feedView";
import membershipView from "views/membershipView";
import newsIssueView from "views/newsIssueView";
import newsItemView from "views/newsItemView";
import newsItemCommentView from "views/newsItemCommentView";
import newsSponsorshipView from "views/newsSponsorshipView";
import pageView from "views/pageView";
import personView from "views/personView";
import podcastView from "views/podcastView";
import podcastSubscriptionView from "views/podcastSubscriptionView";
import postView from "views/postView";
import sponsorView from "views/sponsorView";
import topicView from "views/topicView";
import ts from "../shared/ts";
import FormUI from "components/formUI";
import MembershipView from "./views/membershipView";

let views = {
  EpisodeView: episodeView,
  FeedView: feedView,
  MembershipView: membershipView,
  NewsItemView: newsItemView,
  NewsItemCommentView: newsItemCommentView,
  NewsIssueView: newsIssueView,
  NewsSponsorshipView: newsSponsorshipView,
  PageView: pageView,
  PersonView: personView,
  PodcastView: podcastView,
  PodcastSubscriptionView: podcastSubscriptionView,
  PostView: postView,
  SponsorView: sponsorView,
  TopicView: topicView
};

FormUI.init();

$("a[rel=external]").attr("target", "_blank");
$(".ui.modal").modal();
$(".ui.accordion").accordion();
$(".ui.dropdown.link").dropdown({ action: "nothing" });

$(".js-modal").on("click", function () {
  const modalSelector = $(this).data("modal");
  $(modalSelector).modal("show");
});

$("span.time").each(function () {
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
  onSelect: function (result, response) {
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

  if ($.isFunction(activeView.shared)) activeController.shared();

  if ($.isFunction(activeView[actionName])) activeView[actionName]();
}
