import { u } from "umbrellajs";

export default class PlayButton {
  constructor() {
    this.isPlaying = false;
    this.owner = "";
    u(document).on("DOMContentLoaded", () => {
      if (this.isPlaying && this.owner) {
        this.play();
      }
    });
  }

  belongsTo(subject) {
    this.owner = subject;
    this.play();
  }

  play() {
    this.isPlaying = true;
    this.playBarButton()
      .removeClass("playbar_play")
      .addClass("playbar_pause")
      .text("Pause");
    this.newsItemButton().addClass("is-active").html("<span>Pause</span>");
  }

  pause() {
    this.isPlaying = false;
    this.playBarButton()
      .removeClass("playbar_pause")
      .addClass("playbar_play")
      .text("Play");
    this.newsItemButton().removeClass("is-active").html("<span>Play</span>");
  }

  playBarButton() {
    return u(`a.playbar[data-play="${this.owner}"]`);
  }

  newsItemButton() {
    return u(`a.news_item-toolbar-play_button[data-play="${this.owner}"]`);
  }
}
