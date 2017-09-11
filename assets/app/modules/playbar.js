import { u } from "umbrellajs";

export default class Playbar {
  constructor() {
    this.isPlaying = false;
    this.owner = '';
    u(document).on("turbolinks:load", () => {
      this.isPlaying && this.owner && this.exists() && this.setUI();
    });
  }

  exists() {
    return !!(u(`a[data-play="${this.owner}"]`).length);
  }

  pause() {
    this.isPlaying = false;
    this.resetUI();
  }

  play() {
    this.isPlaying = true;
    this.setUI();
  }

  resetUI() {
    if(u(`a[data-play="${this.owner}"]`).hasClass("playbar_pause")) {
      u(`a[data-play="${this.owner}"]`).removeClass("playbar_pause").addClass("playbar_play").text("Play");
    }
  }

  setUI() {
    u(`a[data-play="${this.owner}"]`).text("Pause").removeClass("playbar_play").addClass("playbar_pause");
  }

  belongsTo(subject) {
    this.resetUI();
    this.owner = subject;
  }
}
