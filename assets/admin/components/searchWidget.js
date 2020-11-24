import Sortable from "sortablejs";
import autosize from "autosize";

import personItem from "templates/personItem.hbs";
import podcastItem from "templates/podcastItem.hbs";
import topicItem from "templates/topicItem.hbs";
import sponsorItem from "templates/sponsorItem.hbs";

export default class SearchWidget {
  constructor(type, parentType, attrName) {
    let $members = $(`.js-${attrName}`);

    if (!$members.length) return;

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
        case "podcast":
          return "<a href='/admin/podcast/new' target='_blank'>Add a Podcast</a>";
          break;
        case "sponsor":
          return "<a href='/admin/sponsors/new' target='_blank'>Add a Sponsor</a>";
          break
        case "topic":
          return "<a href='/admin/topics/new' target='_blank'>Add a Topic</a>";
          break;
      }
    }

    Sortable.create($members[0], {onSort: () => { setPositions(); }});

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
          attrName: attrName,
          id: selected.id,
          name: selected.title,
          handle: selected.description,
          avatarUrl: selected.image,
          index: $members.find(".item").length,
          url: selected.url,
          extras: selected.extras
        }

        switch (type) {
          case "person":
            context.parentIsPodcast = (parentType == "podcast");
            $list.append(personItem(context));
            break;
          case "podcast":
            $list.append(podcastItem(context));
            break;
          case "sponsor":
            $list.append(sponsorItem(context));
            break;
          case "topic":
            $list.append(topicItem(context));
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
        $clicked.children("input").val(true);
        $member.hide();
      } else {
        $member.remove();
      }

      setPositions();
    }).on("click", ".js-retire", function(event) {
      let $clicked = $(this);
      let $member = $clicked.closest(".item");

      if ($clicked.hasClass("positive")) {
        $clicked.children("input").val(true);
        $clicked.removeClass("positive").addClass("negative");
        $clicked.children("i").addClass("slash");
      } else {
        $clicked.children("input").val(false);
        $clicked.removeClass("negative").addClass("positive");
        $clicked.children("i").removeClass("slash");
      }
    })
  }
}
