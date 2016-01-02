import "deps/phoenix_html/web/static/js/phoenix_html"
import pv from "./admin/views/podcast_view"

let views = {
  "PodcastView": pv
}

$("#sidebar").sidebar({context: $("#main")})
$("a[rel=external]").attr("target", "_blank")
$(".ui.dropdown").dropdown()
$(".ui.checkbox").checkbox()

let $body = $("body");
let viewName = $body.data("module").match(/\.(\w+View)$/)[1]
let actionName = $body.data("template").replace(".html", "")

let viewClass = views[viewName]

if (viewClass !== undefined) {
  let activeView = new viewClass()

  if ($.isFunction(activeView.shared))
    activeController.shared();

  if ($.isFunction(activeView[actionName]))
    activeView[actionName]();
}
