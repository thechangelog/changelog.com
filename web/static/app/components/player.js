import Howler from "howler";
import Episode from "components/episode";
import { ajax } from "umbrellajs";
const { Howl } = Howler;

export default class Player {
  constructor(uEl) {
    this.containerEl = uEl;
    this.playerEl = this.containerEl.find(".js-player");

    this.artEl = this.containerEl.find(".js-player-art");
    this.nowPlayingEl = this.containerEl.find(".js-player-now-playing");
    this.titleEl = this.containerEl.find(".js-player-title");
    this.prevNumberEl = this.containerEl.find(".js-player-prev-number");
    this.prevButtonEl = this.containerEl.find(".js-player-prev-button");
    this.nextNumberEl = this.containerEl.find(".js-player-next-number");
    this.nextButtonEl = this.containerEl.find(".js-player-next-button");
    this.scrubberEl = this.containerEl.find(".js-player-scrubber");
    this.trackEl = this.containerEl.find(".js-player-track");
    this.durationEl = this.containerEl.find(".js-player-duration");
    this.currentEl = this.containerEl.find(".js-player-current");

    this.playButtonEl = this.containerEl.find(".js-player-play-button");
    this.backButtonEl = this.containerEl.find(".js-player-back-button");
    this.forwardButtonEl = this.containerEl.find(".js-player-forward-button");

    this.playButtonEl.handle("click", () => {
      if (this.howl.playing()) {
        this.pause();
      } else {
        this.play();
      }
    });
    this.backButtonEl.handle("click", () => { this.seekBy(-15); });
    this.forwardButtonEl.handle("click", () => { this.seekBy(15); });

    this.scrubberEl.on("input", (event) => { this.scrub(event.target.value); });
    this.scrubberEl.on("change", (event) => { this.scrubEnd(event.target.value); });
  }

  start() {
    if (!this.current) return;

    if (this.howl) {
      this.howl.unload();
    }

    this.howl = new Howl({
      html5: true,
      src: [this.current.audio()]
    });

    this.howl.once("load", () => { this.play(); });
  }

  play() {
    if (!this.howl) return;
    requestAnimationFrame(this.step.bind(this));
    this.howl.play();
    this.playButtonEl.addClass("is-playing").removeClass("is-paused is-loading");
  }

  pause() {
    if (!this.howl) return;
    this.howl.pause();
    this.playButtonEl.addClass("is-paused").removeClass("is-playing is-loading");
  }

  seekBy(to) {
    if (!this.howl) return;
    const currentSeek = this.howl.seek() || 0;
    this.seek(currentSeek + to);
  }

  seek(to) {
    if (!this.howl) return;
    if (to < 0) to = 0;
    this.howl.seek(to);
  }

  load(episode) {
    this.resetUI();
    this.playButtonEl.addClass("is-loading");
    ajax(episode, {}, (error, data) => {
      this.current = new Episode(data);
      this.loadUI();
      this.show();
      this.start();
    });
  }

  loadUI() {
    this.artEl.attr("src", this.current.art());
    this.nowPlayingEl.text("Now Playing: " + this.current.nowPlaying());
    this.titleEl.text(this.current.title());
    this.durationEl.text(Episode.formatTime(this.current.duration()));
    this.scrubberEl.attr("max", this.current.duration());

    if (this.current.hasPrev()) {
      this.prevNumberEl.text(this.current.prevNumber());
      this.prevButtonEl.data("play", this.current.prevLocation());
    } else {
      this.prevNumberEl.text("");
      this.prevButtonEl.first().removeAttribute("data-play");
    }

    if (this.current.hasNext()) {
      this.nextNumberEl.text(this.current.nextNumber());
      this.nextButtonEl.data("play", this.current.nextLocation());
    } else {
      this.nextNumberEl.text("");
      this.nextButtonEl.first().removeAttribute("data-play");
    }
  }

  resetUI() {
    this.nowPlayingEl.text("Loading...");
    this.titleEl.text("");
    this.currentEl.text("0:00");
    this.durationEl.text("0:00");
    this.prevNumberEl.text("");
    this.prevButtonEl.first().removeAttribute("data-play");
    this.nextNumberEl.text("");
    this.nextButtonEl.first().removeAttribute("data-play");
    this.scrubberEl.first().value = 0;
    this.trackEl.first().style.width = "0%";
  }

  step() {
    const seek = Math.round(this.howl.seek() || 0);
    const percentComplete = seek / this.current.duration() * 100;

    if (!this.isScrubbing) {
      this.currentEl.text(Episode.formatTime(seek));
      this.scrubberEl.first().value = seek;
      this.trackEl.first().style.width = `${percentComplete}%`;
    }

    if (this.howl.playing()) {
      requestAnimationFrame(this.step.bind(this));
    }
  }

  scrub(to) {
    this.isScrubbing = true;
    const percentComplete = to / this.current.duration() * 100;
    this.currentEl.text(Episode.formatTime(to));
    this.trackEl.first().style.width = `${percentComplete}%`;
  }

  scrubEnd(to) {
    this.isScrubbing = false;
    this.seek(to);
  }

  show() {
    this.playerEl.addClass("podcast-player--is-active");
  }

  hide() {
   this.playerEl.removeClass("podcast-player--is-active");
  }
}
