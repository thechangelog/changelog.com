import BelongsToWidget from "components/belongsToWidget";
import weekLabel from "templates/weekLabel.hbs";

export default class newsSponsorshipView {
  index() {
  }

  new() {
    new BelongsToWidget("sponsor", "sponsor");

    let $weekPicker = $(".js-week-picker");
    let $weeksField = $(".js-weeks");
    let weeks = $weeksField.data("weeks") || [];

    let dateAsValue = function(date) {
      let year = date.getUTCFullYear();
      let month = date.getUTCMonth() + 1;
      let day = date.getUTCDate();
      if (month < 10) month = `0${month}`;
      if (day < 10) day = `0${day}`;
      return `${year}-${month}-${day}`;
    }

    let formatDateString = function(dateString) {
      let [y, m, d] = dateString.split("-");
      return `${m}/${d}/${y.substring(2, 4)}`;
    }

    let renderLabels = function() {
      $weeksField.html("");
      weeks.sort().forEach(function(date) {
        $weeksField.append(weekLabel({
          value: date,
          text: formatDateString(date)
        }));
      });
    }

    $weekPicker.calendar({
      type: "date",
      inline: true,
      firstDayOfWeek: 1,
      isDisabled: function(date, mode) {
        return (mode == "day") && (date.getDay() != 1);
      },
      onChange: function(date, text) {
        let value = dateAsValue(date);
        weeks.push(value);
        weeks = [...new Set(weeks)]; // uniquify
        renderLabels();
      }
    });

    $weeksField.on("click", ".js-remove", function(event) {
      let value = $(this).find("input").val();
      weeks = weeks.filter(function(date) { return date != value; });
      renderLabels();
    });

    renderLabels();
  }

  edit() {
    this.new();
  }
}
