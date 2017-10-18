import BelongsToWidget from "components/belongsToWidget";
import SearchWidget from "components/searchWidget";
import Slugifier from "components/slugifier";
import CalendarField from "components/calendarField";

export default class PostView {
  new() {
    new BelongsToWidget("author", "person");
    new Slugifier("#post_title", "#post_slug");
    new SearchWidget("topic", "post", "topics");
    new CalendarField(".ui.calendar");
  }

  edit() {
    this.new();
  }
}
