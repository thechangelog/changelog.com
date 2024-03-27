import BelongsToWidget from "components/belongsToWidget";
import CalendarField from "components/calendarField";

export default class FeedView {
  new() {
    new BelongsToWidget("person", "person");
    new CalendarField(".ui.calendar");

    $(".js-podcast_ids").on("click", ".card a", function (event) {
      let $clicked = $(this);
      let id = $clicked.data("id");

      if ($clicked.hasClass("disabled")) {
        $clicked.removeClass("disabled");
        $clicked.append(
          `<input type="hidden" name="feed[podcast_ids][]" value="${id}">`
        );
      } else {
        $clicked.addClass("disabled");
        $clicked.find("input").remove();
      }
    });
  }

  edit() {
    this.new();
  }
}
