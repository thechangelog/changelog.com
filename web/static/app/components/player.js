import Howl from "howler";

export default class Player {
  constructor(el) {
    this.el = el;
    this.playlist = [];
  }

  show() {
    this.el.find(".podcast-player").addClass("podcast-player--is-active");
  }

  hide() {
   this.el.find(".podcast-player").removeClass("podcast-player--is-active");
  }
}
