import BelongsToWidget from "components/belongsToWidget";

export default class newsItemCommentView {
  index() {
  }

  new() {
    new BelongsToWidget("author", "person");
  }

  edit() {
    this.new();
  }
}
