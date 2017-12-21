import CalendarField from "components/calendarField";
import ListWidget from "components/listWidget";

export default class newsIssueView {
  index() {
  }

  new() {
    new ListWidget("news_issue", "items");
    new ListWidget("news_issue", "ads");
  }

  edit() {
    this.new();
    new CalendarField(".ui.calendar");
  }
}
