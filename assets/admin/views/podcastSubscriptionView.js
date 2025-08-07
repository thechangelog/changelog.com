import ApexCharts from "apexcharts";
import Modal from "components/modal";

export default class PodcastSubscriptionView {
  constructor() {
    this.chartOptions = {
      chart: {
        type: "bar",
        height: 350
      }
    };
  }

  index() {
    new Modal(".js-import-modal", ".import.modal");

    let chartOptions = this.chartOptions;

    $(".chart").each(function (_index) {
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
}
