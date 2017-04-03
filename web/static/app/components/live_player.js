import { u, ajax } from "umbrellajs";
import Log from "components/log";

export default class LivePlayer {
  constructor(selector) {
    this.selector = selector;
    this.isAttached = false;
    this.streaming = false;
    this.listeners = 0;
    this.audio = new Audio();
    this.audio.type = "audio/mpeg";
    this.audio.autoplay = true;
  }

  check() {
    this.container = u(this.selector);

    if (this.container.length) {
      this.attach();
    } else {
      this.detach();
    }
  }

  attach() {
    // ui
    this.playButton = this.container.find(".js-live-play-button");
    this.liveViewers = this.container.find(".js-live-viewers");
    this.status = this.container.find(".js-live-status");
    this.streamSrc = this.playButton.attr("href");
    // events
    this.playButton.handle("click", () => { this.togglePlayPause(); });
    this.monitorStatus();
    this.monitorId = setInterval(() => { this.monitorStatus(); }, 3000);
    // yup
    this.isAttached = true;
  }

  detach() {
    if (!this.isAttached) {
      return false;
    }

    // events
    this.playButton.off("click");
    clearInterval(this.monitorId);
    // ui
    this.liveViewers.destroy();
    this.status.destroy();
    this.streamSrc.destroy();
  }

  loadUI() {
    this.liveViewers.text(this.listeners);

    if (this.streaming) {
      this.status.text("Live");
      this.container.removeClass("is-upcoming");
    } else {
      this.status.text("Upcoming");
      this.container.addClass("is-upcoming");
    }
  }

  monitorStatus() {
    ajax("/live/status", {}, (error, data) => {
      if (data.streaming && !this.streaming) {
        this.load();
      }

      this.streaming = data.streaming;
      this.listeners = data.listeners;
      this.loadUI();
    });
  }

  togglePlayPause() {
    if (this.isPlaying()) {
      this.pause();
    } else {
      this.play();
    }
  }

  isPlaying() {
    return !this.audio.paused;
  }

  load() {
    this.audio.src = this.streamSrc;
    this.audio.load();
    this.play();
  }

  play() {
    this.audio.play();
    this.container.addClass("is-playing").removeClass("is-paused is-upcoming");
  }

  pause() {
    this.audio.pause();
    this.container.addClass("is-paused").removeClass("is-playing is-upcoming");
  }
}
