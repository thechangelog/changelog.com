export default class Modal {
  constructor(triggerSelector, modalSelector) {
    this.$modal = $(modalSelector).modal();

    $(triggerSelector).on("click", (event) => {
      event.preventDefault();
      this.$modal.modal("show");
    });
  }
}
