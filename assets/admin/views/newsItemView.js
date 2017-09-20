import BelongsToWidget from "components/belongsToWidget";

export default class newsItemView {
  new() {
    new BelongsToWidget("author", "person");
    new BelongsToWidget("source", "source");
    new BelongsToWidget("sponsor", "sponsor");

    $("#news_item_sponsored").on("change", function() {
      if ($(this).is(":checked")) {
        $(".js-sponsor").show();
      } else {
        $(".js-sponsor").hide();
      }
    }).trigger("change");
  }

  edit() {
    this.new();
  }
}
