import BelongsToWidget from "components/belongsToWidget";

export default class BenefitView {
  new() {
    new BelongsToWidget("sponsor", "sponsor");
  }

  edit() {
    this.new();
  }
}
