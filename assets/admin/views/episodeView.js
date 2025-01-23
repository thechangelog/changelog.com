import ApexCharts from "apexcharts";
import Clipboard from "clipboard";
import SearchWidget from "components/searchWidget";
import FilterWidget from "components/filterWidget";
import CalendarField from "components/calendarField";
import ChaptersWidget from "components/chaptersWidget";
import Modal from "components/modal";
import parseTime from "../../shared/parseTime";

export default class EpisodeView {
  constructor() {
    this.chartOptions = {
      chart: {
        type: "line",
        height: 400
      },
      yaxis: {
        decimalsInFloat: 0,
        labels: {
          formatter: function (val) {
            return val.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
          }
        }
      }
    };
  }

  index() {
    new FilterWidget();

    let scheduled = $(".ui.calendar")
      .data("scheduled")
      .map((string) => {
        let date = new Date(string);
        return date.toDateString();
      });

    $(".ui.calendar").calendar({
      type: "date",
      isDisabled: function (date, mode) {
        for (var i = scheduled.length - 1; i >= 0; i--) {
          if (scheduled[i] == date.toDateString()) {
            return true;
          }
        }

        return false;
      }
    });

    let chartOptions = this.chartOptions;

    $(".performance-chart").each(function (_index) {
      let container = this;

      $.getJSON($(container).data("source"), function (data) {
        let options = $.extend(chartOptions, {
          series: data.series,
          title: {
            text: data.title
          },
          legend: {
            position: "top",
            horizontalAlign: "center",
            floating: true
          },
          xaxis: {
            tooltip: {
              enabled: false
            }
          },
          tooltip: {
            x: {
              formatter: function (
                value,
                { _series, seriesIndex, dataPointIndex, _w }
              ) {
                let title = data.series[seriesIndex].data[dataPointIndex].title;
                let slug = data.series[seriesIndex].data[dataPointIndex].x;
                return `${slug}: ${title}`;
              }
            },
            marker: { show: false }
          }
        });

        let chart = new ApexCharts(container, options);
        chart.render();
      });
    });
  }

  youtube() {
    let $csvFileDropZone = $(".js-csv-file");
    let $selectInput = $(".js-episode-select input");
    let outputTextArea = document.querySelector(".js-description-output");

    $csvFileDropZone
      .on("dragover", function (event) {
        event.preventDefault();
        $csvFileDropZone.addClass("secondary");
      })
      .on("dragleave", function (event) {
        $csvFileDropZone.removeClass("secondary");
        event.preventDefault();
      })
      .on("drop", async function (event) {
        event.preventDefault();
        $csvFileDropZone.removeClass("transition").addClass("loading");

        let file = event.originalEvent.dataTransfer.items[0];

        if (file.type.match(/text\/csv/)) {
          let reader = new FileReader();

          reader.onload = async function (e) {
            let response = await fetch(window.location.href, {
              method: "POST",
              headers: {
                "content-type": "application/json",
                "x-csrf-token": document
                  .querySelector("meta[name='csrf-token']")
                  .getAttribute("content")
              },
              body: JSON.stringify({
                id: $selectInput.val(),
                csv: e.target.result
              })
            });
            let json = await response.json();

            outputTextArea.value = json.output;
            $csvFileDropZone.removeClass("loading");

            outputTextArea.dispatchEvent(new Event("autosize:update"));
            outputTextArea.select();
          };

          reader.readAsText(file.getAsFile());
        } else {
          $csvFileDropZone.removeClass("secondary");
        }
      });
  }

  show() {
    let clipboard = new Clipboard(".clipboard.button", {
      target: function (trigger) {
        return trigger.previousElementSibling;
      }
    });

    clipboard.on("success", function (e) {
      $(e.trigger)
        .popup({ variation: "inverted", content: "Copied!" })
        .popup("show");
      e.clearSelection();
    });

    clipboard.on("error", function (e) {
      console.log(e);
    });

    let chartOptions = this.chartOptions;

    $(".chart").each(function (index) {
      let data = $(this).data("chart");

      let options = $.extend(chartOptions, {
        title: {
          text: data.title
        },
        series: data.series,
        xaxis: {
          categories: data.categories
        }
      });

      let chart = new ApexCharts(this, options);
      chart.render();
    });
  }

  new() {
    new SearchWidget("person", "episode", "episode_hosts");
    new SearchWidget("person", "episode", "episode_guests");
    new SearchWidget("sponsor", "episode", "episode_sponsors");
    new SearchWidget("topic", "episode", "episode_topics");
    new CalendarField(".ui.calendar");
    new Modal(".js-title-guide-modal", ".title-guide.modal");
    new Modal(".js-subtitle-guide-modal", ".subtitle-guide.modal");
    new ChaptersWidget("audio", $(".js-episode_sponsors"));
    new ChaptersWidget("plusplus", []);

    let clipboard = new Clipboard(".clipboard.button");

    clipboard.on("success", function (e) {
      $(e.trigger)
        .popup({ variation: "inverted", content: "Copied!" })
        .popup("show");
    });

    clipboard.on("error", function (e) {
      console.log(e);
    });

    let requestedInput = $("input[name='episode[requested]']");
    let requestSelect = $("select[name='episode[request_id]']");

    requestedInput.on("change", function () {
      if (requestedInput.is(":checked")) {
        requestSelect.closest(".field").removeClass("hidden");
      } else {
        requestSelect.closest(".field").addClass("hidden");
        requestSelect.dropdown("clear");
      }
    });

    $("form").on("change", ".js-time-in-seconds", function (event) {
      let currentTime = $(event.target).val();
      let newTime = parseTime(currentTime);

      if (currentTime != newTime) {
        $(event.target).val(newTime);
      }
    });
  }

  edit() {
    this.new();

    new Modal(".js-publish-modal", ".publish.modal");

    let newsInput = $("input[name=news]");
    let thanksInput = $("input[name=thanks]");

    newsInput.on("change", function () {
      if (newsInput.is(":checked")) {
        thanksInput.closest(".checkbox").checkbox("set enabled");
      } else {
        thanksInput
          .closest(".checkbox")
          .checkbox("set disabled")
          .checkbox("uncheck");
      }
    });
  }
}
