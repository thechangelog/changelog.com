import { u, ajax } from "umbrellajs";
import Log from "modules/log";

export default class LivePlayer {
  constructor(selector) {
    this.selector = selector;
    this.isAttached = false;
    this.streaming = false;
    this.failed = false;
    this.listeners = 0;
    this.audio = new Audio();
    this.audio.type = "audio/mpeg";
    this.audio.autoplay = true;
    this.audio.addEventListener("error", (e) => { this.loadFailed(e) });
  }

  check() {
    this.container = u(this.selector);

    // are we on /live?
    if (this.container.length) {
      this.attach();
    } else {
      this.detach();
      this.checkStatusOnce();
    }
  }

  attach() {
    // ui
    this.playButton = this.container.find(".js-live-play-button");
    this.liveViewers = this.container.find(".js-live-viewers");
    this.status = this.container.find(".js-live-status");
    this.streamSrc = this.playButton.attr("href");
    this.title = this.container.find(".js-title");
    // events
    this.playButton.handle("click", () => { this.togglePlayPause(); });
    this.monitorStatus();
    this.monitorId = setInterval(() => { this.monitorStatus(); }, 3000);
    // yup
    this.isAttached = true;
  }

  detach() {
    if (!this.isAttached) return false;
    // events
    this.playButton.off("click");
    clearInterval(this.monitorId);
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

  checkStatusOnce() {
    ajax("/live/status", {}, (error, data) => {
      if (data.streaming) {
        this.showLiveIndicator();
      } else {
        this.hideLiveIndicator();
      }
    });
  }

  monitorStatus() {
    if (this.failed) {
      return;
    }

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
    Log.track("Live Player", "Play", this.title.text());
  }

  loadFailed(event) {
    this.failed = true;
    this.status.text("Error");
    this.container.removeClass("is-upcoming");
    console.log("Stream failed to load", "The error:", event.target.error, "The URL", this.audio.src);
    alert("Doh! Our stream failed to load. Maybe you're behind a firewall that blocks port 1882? If not, try refreshing!");
  }

  play() {
    this.audio.play().then(_ => {
      this.container.addClass("is-playing").removeClass("is-paused is-upcoming");
    }).catch(error => {
      console.log("failed to play", error);
    });
  }

  pause() {
    this.audio.pause();
    this.container.addClass("is-paused").removeClass("is-playing is-upcoming");
  }

  showLiveIndicator() {
    u(".js-live-indicator").removeClass("is-hidden");
  }

  hideLiveIndicator() {
   u(".js-live-indicator").addClass("is-hidden");
  }
}
