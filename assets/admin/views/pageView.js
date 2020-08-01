import Modal from "components/modal";

export default class pageView {
  index() {
    $(".modal-button").each(function () {
      let modalIdSelector = $(this).attr("data-target");
      let buttonId = $(this).attr("id");
      new Modal(`#${buttonId}`, modalIdSelector);
    });
  }
}
