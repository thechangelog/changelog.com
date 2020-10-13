import Sortable from "sortablejs";
import linkItem from "templates/linkItem.hbs";

export default class ListWidget {
  constructor(parentType, attrName) {
    let $members = $(`.js-${attrName}`);
    let $add = $members.siblings(".js-add");

    let setPositions = function() {
      $members.find(".item").each(function(index) {
        let $item = $(this);
        $item.find("input.js-position").val(index + 1);
        $item.find(".js-position-display").text(index + 1);
      });
    }

    Sortable.create($members.get(0), {onSort: () => { setPositions(); }});

    $add.on("click", function(event) {
      event.preventDefault();
      let index = $members.find(".item").length;
      let context = {
        parentType: parentType,
        attrName: attrName,
        index: index,
        position: index + 1
      }

      $members.append(linkItem(context));
    });

    $members.on("click", ".js-image", function(event) {
      let $clicked = $(this);
      let $icon = $clicked.find("i");
      let $input = $clicked.find("input");

      if ($icon.hasClass("slash")) {
        $input.val(true);
        $icon.removeClass("slash");
      } else {
        $input.val(false);
        $icon.addClass("slash");
      }
    })

    $members.on("click", ".js-remove", function(event) {
      let $clicked = $(this);
      let $member = $clicked.closest(".item");

      if ($member.hasClass("persisted")) {
        $clicked.siblings("input").val(true);
        $member.hide();
      } else {
        $member.remove();
      }

      setPositions();
    })
  }
}
