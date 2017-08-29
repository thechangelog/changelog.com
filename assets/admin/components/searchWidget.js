import Sortable from "sortablejs";
import autosize from "autosize";

import personItem from "templates/personItem.hbs";
import channelItem from "templates/channelItem.hbs";
import sponsorItem from "templates/sponsorItem.hbs";

export default class SearchWidget {
  constructor(type, parentType, relationType) {
    let $members = $(`.js-${relationType}`);
    let $search = $members.siblings(".search");

    var setPositions = function() {
      $members.find(".item").each(function(index) {
        let $item = $(this);
        $item.find("input.js-position").val(index + 1);
        $item.find(".js-position-display").text(index + 1);
      });
    }

    var noResultsMessage = function() {
      switch (type) {
        case "person":
          return "<a href='/admin/people/new' target='_blank'>Add a Person</a>";
          break;
        case "sponsor":
          return "<a href='/admin/sponsors/new' target='_blank'>Add a Sponsor</a>";
          break
        case "channel":
          return "<a href='/admin/channels/new' target='_blank'>Add a Channel</a>";
          break;
      }
    }

    Sortable.create($members[0], {
      onSort: function(event) {
        setPositions();
      }
    });

    $search.search({
      apiSettings: {
        url: `/admin/search/${type}?q={query}&f=json`
      },
      fields: {
        url: null // so the returned url isn't followed on click
      },
      onSelect: function(selected) {
        let $list = $search.siblings(".list");

        let context = {
          parentType: parentType,
          relationType: relationType,
          id: selected.id,
          name: selected.title,
          handle: selected.description,
          avatarUrl: selected.image,
          index: $members.find(".item").length,
          extras: selected.extras
        }

        switch (type) {
          case "person":
            $list.append(personItem(context));
            break;
          case "sponsor":
            $list.append(sponsorItem(context));
            break;
          case "channel":
            $list.append(channelItem(context));
            break;
        }

        setPositions();
        autosize($("textarea"));

        setTimeout(function() {
          $search.search("set value", "");
        }, 10);
      },
      error: {
        noResults: noResultsMessage()
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
