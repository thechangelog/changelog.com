import BelongsToWidget from "components/belongsToWidget";
import FormUI from "components/formUI";
import weekLabel from "templates/weekLabel.hbs";
import adSegment from "templates/adSegment.hbs";
import Clipboard from "clipboard";
import gup from "../../shared/gup";

export default class newsSponsorshipView {
  index() {
  }

  show() {
    let clipboard = new Clipboard(".clipboard.button");

    clipboard.on("success", function(e) {
      $(e.trigger).popup({variation: "inverted", content: "Copied!"}).popup("show");
    });

    clipboard.on("error", function(e) { console.log(e); });
  }

  schedule() {
    let past = $("tr.past");
    let pastButton = $(".js-toggle-past");
    let hidingPast = false;

    pastButton.on("click", function() {
      if (hidingPast) {
        past.removeClass("hidden");
        pastButton.text("Hide Past");
        hidingPast = false;
      } else {
        past.addClass("hidden");
        pastButton.text("Show Past");
        hidingPast = true;
      }
    });

    let currentYear = new Date().getFullYear();
    let effectiveYear = gup("year") || currentYear;

    // auto-hide past when viewing current year
    if (effectiveYear == currentYear) {
      pastButton.trigger("click");
    }
  }

  new() {
    new BelongsToWidget("sponsor", "sponsor");
    this._handleAds();
    this._handleWeeks();
  }

  edit() {
    this.new();
  }

  _handleAds() {
    let $container = $(".js-ads");
    let $addButton = $(".js-add-ad");

    $addButton.on("click", function() {
      let nextIndex = $container.find(".segment").length;
      $container.append(adSegment({index: nextIndex}));
      FormUI.refresh();
    });

    $container.on("click", ".js-remove", function(event) {
      if (!confirm("Are you sure?")) return false;

      let $clicked = $(this);
      let $ad = $clicked.closest(".segment");

      if ($ad.hasClass("persisted")) {
        $ad.find("input[type=hidden]:first").val(true);
        $ad.hide();
      } else {
        $ad.remove();
      }
    });

    $container.on("change", ".js-newsletter", function(event) {
      let $clicked = $(this);

      if ($clicked.checkbox("is checked")) {
        $(".js-newsletter").not($clicked).checkbox("uncheck");
      }
    });
  }

  _handleWeeks() {
    let $container = $(".js-weeks");
    let weeks = $container.data("weeks") || [];
    let $picker = $(".js-week-picker");
    let $addButton = $(".js-add-weeks");

    let dateAsValue = function(date) {
      let year = date.getFullYear();
      let month = date.getMonth() + 1;
      let day = date.getDate();
      if (month < 10) month = `0${month}`;
      if (day < 10) day = `0${day}`;
      return `${year}-${month}-${day}`;
    }

    let formatDateString = function(dateString) {
      let [y, m, d] = dateString.split("-");
      return `${m}/${d}/${y.substring(2, 4)}`;
    }

    let renderLabels = function() {
      $container.html("");
      weeks.sort().forEach(function(date) {
        $container.append(weekLabel({
          value: date,
          text: formatDateString(date)
        }));
      });
    }

    let isDateDisabled = function(date, mode) {
      return (mode == "day") && (date.getDay() != 1);
    }

    $picker.calendar({
      type: "date",
      inline: true,
      firstDayOfWeek: 1,
      isDisabled: isDateDisabled,
      onChange: function(date, text, mode) {
        if (!isDateDisabled(date, mode)) {
          let value = dateAsValue(date);
          weeks.push(value);
          weeks = [...new Set(weeks)]; // uniquify
          renderLabels();
        }
      }
    });

    $addButton.on("click", function() {
      $addButton.hide();
      $picker.show();
    });

    $container.on("click", ".js-remove", function(event) {
      let value = $(this).find("input").val();
      weeks = weeks.filter(function(date) { return date != value; });
      renderLabels();
    });

    $picker.hide();
    renderLabels();
  }
}
