import SearchWidget from "components/searchWidget";
import CalendarField from "components/calendarField";

export default class EpisodeView {
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
