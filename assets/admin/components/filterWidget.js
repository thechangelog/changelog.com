export default class FilterWidget {
  constructor() {
    $(".js-filter").on("change", function (event) {
      let filter = $(event.target).val();
      if (filter == "" || filter == "default") {
        window.location = `${location.pathname}`;
      } else {
        window.location = `${location.pathname}?filter=${filter}`;
      }
    });
  }
}
