import host_item from "../../admin/templates/host_item"

export default class PodcastView {
  new() {
    let $personSearch = $(".person.search")
    let $hosts = $(".js-hosts")

    var setHostPositions = function() {
      $hosts.find(".item").each(function(index) {
        console.log(index + 1);
        $(this).find("input.js-position").val(index + 1)
      })
    }

    Sortable.create($hosts[0], {
      onSort: function(event) {
        setHostPositions()
      }
    });

    $personSearch.search({
      apiSettings: {
        url: "/admin/search?t=person&q={query}"
      },
      onSelect: function(selected) {
        let $list = $personSearch.siblings(".list")

        let context = {
          id: selected.id,
          name: selected.title,
          handle: selected.description,
          avatar_url: selected.image,
          index: $hosts.find(".item").length
        }

        $list.append(host_item(context))
        setHostPositions()

        setTimeout(function() {
          $personSearch.search("set value", "")
        }, 10);
      },
      error: {
        noResults: "<a href='/admin/people/new' target='_blank'>Add a Person</a>"
      }
    })

    $hosts.on("click", ".js-remove", function(event) {
      let $clicked = $(this)
      let $hostItem = $clicked.closest(".item")

      if ($hostItem.hasClass("persisted")) {
        $clicked.siblings("input").val(true)
        $hostItem.hide()
      } else {
        $hostItem.remove()
      }

      setHostPositions()
    })
  }

  edit() {
    this.new()
  }
}
