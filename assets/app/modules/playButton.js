import { u } from "umbrellajs";

export default class PlayButton {
  constructor() {
    this.isPlaying = false;
    this.owner = "";
    u(document).on("turbolinks:load", () => {
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
    this.playBarButton().removeClass("playbar_play").addClass("playbar_pause").text("Pause");
    this.newsItemButton().addClass("is-active").text("Pause");
  }

  pause() {
    this.isPlaying = false;
    this.playBarButton().removeClass("playbar_pause").addClass("playbar_play").text("Play");
    this.newsItemButton().removeClass("is-active").text("Play");
  }

  playBarButton() {
    return u(`a.playbar[data-play="${this.owner}"]`);
  }

  newsItemButton() {
    return u(`a.news_item-toolbar-button--play[data-play="${this.owner}"]`);
  }
}
