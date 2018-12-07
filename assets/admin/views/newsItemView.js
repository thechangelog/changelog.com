import Sortable from "sortablejs";
import BelongsToWidget from "components/belongsToWidget";
import SearchWidget from "components/searchWidget";
import CalendarField from "components/calendarField";
import Modal from "components/modal";
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
    new BelongsToWidget("submitter", "person");
    new CalendarField(".ui.calendar");
    new Modal(".js-style-guide-modal", ".style-guide.modal");

    $("form").on("click", ".js-schedule", function(event) {
      event.preventDefault();

      $(this)
        .removeClass("js-schedule")
        .removeClass("secondary")
        .addClass("primary")
        .closest(".column")
        .siblings()
        .hide();

      $(".js-published-at")
        .removeClass("hidden")
        .find("input[type=text]")
        .trigger("click");
    });

    if ($(".js-quick-form").length) {
      $(".ui.menu").remove();
      $("h1").remove();
      $(".ui.very.padded.segment").removeClass("very padded");
    }

    let $images = $(".js-image-options");

    ($images.data("options") || []).forEach(function(url) {
      let img = new Image();
      img.setAttribute("style", "display: none");
      img.setAttribute("class", "ui image");
      img.src = url;
      img.onload = function() {
        if (this.naturalWidth >= 200 && this.naturalHeight > 200) {
          this.setAttribute("title", `${this.naturalWidth} x ${this.naturalHeight}`);
          this.setAttribute("style", "display: inline-block;");
        } else {
          this.remove();
        }
      };
      $images.append(img);
    });

    $images.on("click", "img", function() {
      let $clicked = $(this);
      $(".use-url")
        .trigger("click")
        .closest(".field")
        .find("input[type=text]")
        .val($clicked.attr("src"));

      $clicked.addClass("selected");
      $clicked.siblings("img").removeClass("selected");
    });
  }

  edit() {
    this.new();
  }
}
