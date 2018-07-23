import SearchWidget from "components/searchWidget";
import CalendarField from "components/calendarField";
import Modal from "components/modal";
import Clipboard from "clipboard";

export default class EpisodeView {
  index() {
    let scheduled = $(".ui.calendar").data("scheduled").map((string) => {
      let date = new Date(string);
      return date.toDateString();
    });

    $(".ui.calendar").calendar({
      type: "date",
      isDisabled: function (date, mode) {
        for (var i = scheduled.length - 1; i >= 0; i--) {
          if (scheduled[i] == date.toDateString()) {
            return true;
          }
        }

        return false;
      }
    });
  }

  show() {
    let clipboard = new Clipboard(".clipboard.button", {
      target: function(trigger) {
        return trigger.previousElementSibling;
      }
    });

    clipboard.on("success", function(e) {
      $(e.trigger).popup({variation: "inverted", content: "Copied!"}).popup("show");
      e.clearSelection();
    });

    clipboard.on("error", function(e) {
      console.log(e);
    });
  }

  new() {
    new SearchWidget("person", "episode", "hosts");
    new SearchWidget("person", "episode", "guests");
    new SearchWidget("sponsor", "episode", "sponsors");
    new SearchWidget("topic", "episode", "topics");
    new CalendarField(".ui.calendar");
  }

  edit() {
    this.new();

    new Modal(".js-publish-modal", ".publish.modal");

    let newsInput = $("input[name=news]");
    let thanksInput = $("input[name=thanks]");

    newsInput.on("change", function() {
      if (newsInput.is(":checked")) {
        thanksInput.closest(".checkbox").checkbox("set enabled");
      } else {
        thanksInput.closest(".checkbox").checkbox("set disabled").checkbox("uncheck");
      }
    });
  }
}
