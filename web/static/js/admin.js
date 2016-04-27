import "phoenix_html"
import pv from "./admin/views/podcastView"
import ev from "./admin/views/episodeView"

let views = {
  "PodcastView": pv,
  "EpisodeView": ev
}

$("#sidebar").sidebar({context: $("#main")})
$("a[rel=external]").attr("target", "_blank")
$("input[readonly]").popup({
  content: "Read-only because danger. Use the console if you really need to edit this.",
  variation: "very wide"
})
$(".ui.dropdown").dropdown()
$(".ui.checkbox").checkbox()
$(".ui.button, [data-popup=true]").popup()

let $body = $("body")
let viewName = $body.data("module").match(/\.(\w+View)$/)[1]
let actionName = $body.data("template").replace(".html", "")

let viewClass = views[viewName]

if (viewClass !== undefined) {
  let activeView = new viewClass()

  if ($.isFunction(activeView.shared))
    activeController.shared()

  if ($.isFunction(activeView[actionName]))
    activeView[actionName]()
}
