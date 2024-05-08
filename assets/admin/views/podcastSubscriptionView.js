import ApexCharts from "apexcharts";

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
    let chartOptions = this.chartOptions;

    $(".chart").each(function (_index) {
      let data = $(this).data("chart");
      console.log(data);
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
