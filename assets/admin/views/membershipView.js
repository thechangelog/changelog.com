import BelongsToWidget from "components/belongsToWidget";
import FilterWidget from "components/filterWidget";

export default class MembershipView {
  new() {
    new BelongsToWidget("person", "person");
  }

  edit() {
    this.new();
  }

  index() {
    new FilterWidget();
  }
}
