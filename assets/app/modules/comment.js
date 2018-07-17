import { u, ajax } from "umbrellajs";

export default class Commment {
  constructor() {
    // ui
    this.toggleButton = u(".js-toggle_comment");
    // events
    this.toggleButton.on("click", (event) => {
      u(event.currentTarget).closest(".comment").toggleClass("is-collapsed");
    });
  }
}
