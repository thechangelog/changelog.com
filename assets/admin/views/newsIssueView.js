import Sortable from "sortablejs";

export default class newsIssueView {
  index() {
  }

  new() {
    let $ads = $(".js-ads");
    let $items = $(".js-items");

    Sortable.create($ads.get(0), {
      draggable: ".item",
      handle: ".move.icon",
      onSort: function(event) {
        $ads.find(".item").each(function(index) {
          $(this).find("input.js-position").val(index + 1);
        });
      }
    });

    Sortable.create($items.get(0), {
      draggable: ".item",
      handle: ".move.icon",
      onSort: function(event) {
        $items.find(".item").each(function(index) {
          $(this).find("input.js-position").val(index + 1);
        });
      }
    });
  }

  edit() {
    this.new();
  }
}
