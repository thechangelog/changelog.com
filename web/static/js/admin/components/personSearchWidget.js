import personItem from "../templates/personItem"

export default class PersonSearchWidget {
  constructor(parentType, relationType) {
    let $search = $(".person.search")
    let $members = $(`.js-${relationType}`)

    var setPositions = function() {
      $members.find(".item").each(function(index) {
        $(this).find("input.js-position").val(index + 1)
      })
    }

    Sortable.create($members[0], {
      onSort: function(event) {
        setPositions()
      }
    })

    $search.search({
      apiSettings: {
        url: "/admin/search?t=person&q={query}"
      },
      onSelect: function(selected) {
        let $list = $search.siblings(".list")

        let context = {
          parentType: parentType,
          relationType: relationType,
          id: selected.id,
          name: selected.title,
          handle: selected.description,
          avatarUrl: selected.image,
          index: $members.find(".item").length
        }

        $list.append(personItem(context))
        setPositions()

        setTimeout(function() {
          $search.search("set value", "")
        }, 10);
      },
      error: {
        noResults: "<a href='/admin/people/new' target='_blank'>Add a Person</a>"
      }
    })

    $members.on("click", ".js-remove", function(event) {
      let $clicked = $(this)
      let $member = $clicked.closest(".item")

      if ($member.hasClass("persisted")) {
        $clicked.siblings("input").val(true)
        $member.hide()
      } else {
        $member.remove()
      }

      setPositions()
    })
  }
}
