import BelongsToWidget from "components/belongsToWidget";
import SearchWidget from "components/searchWidget";
import Slugifier from "components/slugifier";
import CalendarField from "components/calendarField";
import Modal from "components/modal";

export default class PostView {
  new() {
    new BelongsToWidget("author", "person");
    new Slugifier("#post_title", "#post_slug");
    new SearchWidget("topic", "post", "topics");
    new CalendarField(".ui.calendar");
  }

  edit() {
    this.new();

    new Modal(".js-publish-modal", ".publish.modal");
  }
}
