import linkItem from "../templates/linkItem"

export default class ListWidget {
  constructor(parentType, relationType) {
    let $members = $(`.js-${relationType}`);
    let $add = $members.siblings(".js-add");

    var setPositions = function() {
      $members.find(".item").each(function(index) {
        let $item = $(this);
        $item.find("input.js-position").val(index + 1);
        $item.find(".js-position-display").text(index + 1);
      });
    }

    Sortable.create($members[0], {
      onSort: function(event) {
        setPositions();
      }
    });

    $add.on("click", function(event) {
      event.preventDefault();
      let index = $members.find(".item").length;
      let context = {
        parentType: parentType,
        relationType: relationType,
        index: index,
        position: index + 1
      }

      $members.append(linkItem(context));
    });

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
