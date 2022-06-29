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
          formatter: function(val) {
            return val.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
           }
         }
      }
    }
  }

  index() {
    new FilterWidget();

    let scheduled = $(".ui.calendar").data("scheduled").map((string) => {
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

    $(".performance-chart").each(function(_index) {
      let container = this;

      $.getJSON($(container).data("source"), function(data) {
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
              formatter: function(value, {_series, seriesIndex, dataPointIndex, _w}) {
                let title = data.series[seriesIndex].data[dataPointIndex].title;
                let slug = data.series[seriesIndex].data[dataPointIndex].x;
                return `${slug}: ${title}`;
              }
            },
            marker: {show: false}
          }
        });

        let chart = new ApexCharts(container, options);
        chart.render();
      });
    });
  }

  show() {
    let clipboard = new Clipboard(".clipboard.button", {
      target: function(trigger) {
        return trigger.previousElementSibling;
      }
    });

    clipboard.on("success", function(e) {
      $(e.trigger).popup({variation: "inverted", content: "Copied!"}).popup("show");
      e.clearSelection();
    });

    clipboard.on("error", function(e) {
      console.log(e);
    });

    let chartOptions = this.chartOptions;

    $(".chart").each(function(index) {
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
    new SearchWidget("person", "episode", "episode_hosts")
    new SearchWidget("person", "episode", "episode_guests")
    new SearchWidget("sponsor", "episode", "episode_sponsors")
    new SearchWidget("topic", "episode", "episode_topics")
    new CalendarField(".ui.calendar")
    new Modal(".js-title-guide-modal", ".title-guide.modal")
    new Modal(".js-subtitle-guide-modal", ".subtitle-guide.modal")

    let clipboard = new Clipboard(".clipboard.button")

    clipboard.on("success", function(e) {
      $(e.trigger).popup({variation: "inverted", content: "Copied!"}).popup("show")
    })

    clipboard.on("error", function(e) { console.log(e) })

    let requestedInput = $("input[name='episode[requested]']")
    let requestSelect = $("select[name='episode[request_id]']")

    requestedInput.on("change", function() {
      if (requestedInput.is(":checked")) {
        requestSelect.closest(".field").show();
      } else {
        requestSelect.closest(".field").hide();
        requestSelect.dropdown("clear");
      }
    })

    let liveInput = $("input[name='episode[recorded_live]']")
    let youTubeInputContainer = $("input[name='episode[youtube_id]']").closest("div")

    liveInput.on("change", function () {
      if (liveInput.is(":checked")) {
        youTubeInputContainer.removeClass("hidden")
      } else {
        youTubeInputContainer.addClass("hidden")
      }
    })

    $("form").on("change", ".js-time-in-seconds", function(event) {
      let currentTime = $(event.target).val()
      let newTime = parseTime(currentTime)

      if (currentTime != newTime) {
        $(event.target).val(newTime)
      }
    })

    async function getAsByteArray(file) {
      return new Uint8Array(await readFile(file))
    }

    function readFile(file) {
      return new Promise((resolve, reject) => {
        // Create file reader
        let reader = new FileReader()

        // Register event listeners
        reader.addEventListener("loadend", e => resolve(e.target.result))
        reader.addEventListener("error", reject)

        // Read file
        reader.readAsArrayBuffer(file)
      })
    }

    let wavFileDropZone = $(".js-wav-file")
    let episodeSponsors = $(".js-episode_sponsors").children(".item")

    wavFileDropZone.on("dragover", function(event) {
      event.preventDefault()
      wavFileDropZone.addClass("secondary")
    })
    .on("dragleave", function(event) {
      wavFileDropZone.removeClass("secondary")
      event.preventDefault()
    })
    .on("drop", async function(event) {
      event.preventDefault()

      let file = event.originalEvent.dataTransfer.items[0]

      wavFileDropZone.removeClass("secondary").find("tbody").html("")

      if (file.type.match(/audio\/(x-)?wav/)) {
        wavFileDropZone.addClass("loading")

        let byteFile = await getAsByteArray(file.getAsFile())

        let wav = new wavefile.WaveFile()

        wav.fromBuffer(byteFile)

        wavFileDropZone.find("table").removeClass("hidden")

        let markers = wav.listCuePoints()
        let sponsors = markers.filter(m => m.label.match(/Sponsor:\s/))

        if (sponsors.length == episodeSponsors.length) {
          sponsors.forEach((marker, index) => {
            let name = marker.label
            let start = Math.round((marker.position / 1000) * 1000) / 1000
            let end = Math.round((marker.end / 1000) * 1000) / 1000
            let td = `<td>${name}</td><td>${(start)}</td><td>${end}</td>`

            let sponsorItem = $(episodeSponsors[index])

            if (sponsorItem.length) {
              let sponsorTitle = sponsorItem.find("input[name*=title]").val()
              let status = name.match(new RegExp(sponsorTitle, "i")) ? "✅" : "❌"

              sponsorItem.find("input[name*=starts_at]").val(start)
              sponsorItem.find("input[name*=ends_at]").val(end)

              wavFileDropZone.find("tbody").append(`<tr>${td}<td>${status}</td></tr>`)
            }
          })
        } else {
          wavFileDropZone.find("table").addClass("hidden")
          alert(`Episode has ${episodeSponsors.length} sponsors but wav file has ${sponsors.length}`);
        }
      }

      wavFileDropZone.removeClass("loading")
    })

    new ChaptersWidget("audio")
    new ChaptersWidget("plusplus")
  }

  edit() {
    this.new();

    new Modal(".js-publish-modal", ".publish.modal");

    let newsInput = $("input[name=news]");
    let thanksInput = $("input[name=thanks]");

    newsInput.on("change", function() {
      if (newsInput.is(":checked")) {
        thanksInput.closest(".checkbox").checkbox("set enabled");
      } else {
        thanksInput.closest(".checkbox").checkbox("set disabled").checkbox("uncheck");
      }
    });
  }
}
