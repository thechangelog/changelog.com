import SearchWidget from "components/searchWidget";
import CalendarField from "components/calendarField";
import Clipboard from "clipboard";

export default class EpisodeView {
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
    new SearchWidget("channel", "episode", "channels");
    new CalendarField(".ui.calendar");
  }

  edit() {
    this.new();
  }
}
