import Sortable from "sortablejs";

export default class newsIssueView {
  index() {
  }

  new() {
    let $items = $(".js-items");

    let setPositions = function() {
      $items.find(".item").each(function(index) {
        $(this).find("input.js-position").val(index + 1);
      });
    }

    Sortable.create($items.get(0), {
      draggable: ".item",
      handle: ".move.icon",
      onSort: function(event) {
        setPositions();
      }
    });
  }

  edit() {
    this.new();
  }
}
