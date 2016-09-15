import Howler from "howler";
import { ajax, u } from "umbrellajs";

const { Howl } = Howler;

class Episode {
  static formatTime(secs) {
    const minutes = Math.floor(secs / 60) || 0;
    const seconds = (secs - minutes * 60) || 0;
    return minutes + ':' + (seconds < 10 ? '0' : '') + seconds;
  }

  constructor(data) {
    this.prev = data.prev;
    this.next = data.next;
    delete data.prev;
    delete data.nex;
    this.ep = data;
  }

  art() {
    return this.ep.art_url;
  }

  audio() {
    return this.ep.audio_url;
  }

  duration() {
    return this.ep.duration;
  }

  hasPrev() {
    return !!this.prev;
  }

  hasNext() {
    return !!this.next;
  }

  nowPlaying() {
    if (this.ep.number) {
      return `${this.ep.podcast} #${this.ep.number}`
    } else {
      return this.ep.podcast;
    }
  }

  prevNumber() {
    return `#${this.prev.number}`;
  }

  prevLocation() {
    return this.prev.location;
  }

  nextNumber() {
    return `#${this.next.number}`;
  }

  nextLocation() {
    return this.next.location;
  }

  title() {
    return this.ep.title;
  }
}

export default class Player {
  constructor(selector) {
    this.containerEl = u(selector);
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
    this.pauseButtonEl = this.containerEl.find(".js-player-pause-button");
    this.backButtonEl = this.containerEl.find(".js-player-back-button");
    this.forwardButtonEl = this.containerEl.find(".js-player-forward-button");

    this.playButtonEl.handle("click", () => { this.play(); });
    this.pauseButtonEl.handle("click", () => { this.pause(); });
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
    this.playButtonEl.addClass("podcast-player-button--is-hidden");
    this.pauseButtonEl.removeClass("podcast-player-button--is-hidden");
  }

  pause() {
    if (!this.howl) return;
    this.howl.pause();
    this.playButtonEl.removeClass("podcast-player-button--is-hidden");
    this.pauseButtonEl.addClass("podcast-player-button--is-hidden");
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
    ajax(episode, {}, (error, data) => {
      this.current = new Episode(data);
      this.updateUI();
      this.show();
      this.start();
    })
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

  updateUI() {
    this.artEl.attr("src", this.current.art());
    this.nowPlayingEl.text(this.current.nowPlaying());
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

  show() {
    this.playerEl.addClass("podcast-player--is-active");
  }

  hide() {
   this.playerEl.removeClass("podcast-player--is-active");
  }
}
