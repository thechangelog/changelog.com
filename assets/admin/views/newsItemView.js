import Sortable from "sortablejs";
import BelongsToWidget from "components/belongsToWidget";
import SearchWidget from "components/searchWidget";
import Clipboard from "clipboard";

export default class newsItemView {
  index() {
    let $queue = $(".js-queue");

    if ($queue.length) {
      Sortable.create($queue.get(0), {
        draggable: "tr",
        handle: ".icon",
        onSort: function(event) {
          $.ajax({
            type: "post",
            url: `/admin/news/items/${$(event.item).data("id")}/move`,
            data: {position: event.newIndex},
            headers: {"x-csrf-token": $queue.data("csrf")}
          });
        }
      });
    }

    let clipboard = new Clipboard(".clipboard.button");

    clipboard.on("success", function(e) {
      $(e.trigger).popup({variation: "inverted", content: "Copied!"}).popup("show");
    });

    clipboard.on("error", function(e) { console.log(e); });
  }

  new() {
    new SearchWidget("topic", "news_item", "topics");
    new BelongsToWidget("logger", "person");
    new BelongsToWidget("author", "person");
    new BelongsToWidget("source", "news_source");

    if ($(".js-quick-form").length) {
      $(".ui.menu").remove();
      $("h1").remove();
      $(".ui.very.padded.segment").removeClass("very padded");
    }
  }

  edit() {
    this.new();
  }
}
