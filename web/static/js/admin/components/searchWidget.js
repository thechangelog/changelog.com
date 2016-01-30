import personItem from "../templates/personItem"
import topicItem from "../templates/topicItem"

export default class SearchWidget {
  constructor(type, parentType, relationType) {
    let $members = $(`.js-${relationType}`)
    let $search = $members.siblings(".search")

    var setPositions = function() {
      $members.find(".item").each(function(index) {
        $(this).find("input.js-position").val(index + 1)
      })
    }

    var noResultsMessage = function() {
      switch (type) {
        case "person":
          return "<a href='/admin/people/new' target='_blank'>Add a Person</a>"
          break
        case "topic":
          return "<a href='/admin/topics/new' target='_blank'>Add a Topic</a>"
          break
      }
    }

    Sortable.create($members[0], {
      onSort: function(event) {
        setPositions()
      }
    })

    $search.search({
      apiSettings: {
        url: `/admin/search?t=${type}&q={query}`
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

        switch (type) {
          case "person":
            $list.append(personItem(context))
            break
          case "topic":
            $list.append(topicItem(context))
            break
        }

        setPositions()

        setTimeout(function() {
          $search.search("set value", "")
        }, 10);
      },
      error: {
        noResults: noResultsMessage()
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
