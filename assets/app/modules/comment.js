import { u, ajax } from "umbrellajs";

export default class Commment {
  constructor() {
    // ui
    this.toggleButton = u(".js-toggle_comment");
    this.permalink = u(".js-permalink");
    // events
    this.toggleButton.on("click", (event) => {
      u(event.currentTarget).closest(".comment").toggleClass("is-collapsed");
    });

    this.permalink.on("click", (event) => {
      event.preventDefault();
      const target = u(event.target);
      u(".comment").removeClass("is-permalink");
      target.closest(".comment").toggleClass("is-permalink").removeClass("is-collapsed");
      location.hash = target.attr("href");
    });
  }
}
