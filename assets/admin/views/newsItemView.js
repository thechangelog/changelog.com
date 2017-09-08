import BelongsToWidget from "components/belongsToWidget";

export default class newsItemView {
  new() {
    new BelongsToWidget("author", "person");
    new BelongsToWidget("source", "source");
  }

  edit() {
    this.new();
  }
}
