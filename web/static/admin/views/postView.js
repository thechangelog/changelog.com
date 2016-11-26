import SearchWidget from "components/searchWidget";
import Slugifier from "components/slugifier";
import CalendarField from "components/calendarField";

export default class PostView {
  new() {
    $(".remote.search.dropdown").dropdown({
      fields: {name: "title", value: "id"},
      apiSettings: {
        url: `/admin/search/person?q={query}&f=json`
      }
    });

    new Slugifier("#post_title", "#post_slug");
    new SearchWidget("channel", "post", "channels");
    new CalendarField(".ui.calendar");
  }

  edit() {
    this.new();
  }
}
