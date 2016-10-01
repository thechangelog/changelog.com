import Howler from "howler";
import Episode from "components/episode";
import { u, ajax } from "umbrellajs";
const { Howl } = Howler;

export default class Player {
  constructor(selector) {
    // not using turbolinks:load event because we want this to run exactly once
    window.onload = () => {
      // instantiate our Howl up front so that mobile devices are enabled.
      // if we get a new Howl for each call to `start`, user interaction resets.
      this.howl = new Howl({html5: true, src: [""]});
      this.attachUI(selector);
      this.attachEvents();
    }
  }

  isHowlReady() {
    return this.howl.state() != "unloaded";
  }

  isPlaying() {
    return this.howl.playing();
  }

  start() {
    if (!this.episode) return;
    this.howl.unload();
    this.howl._src = [this.episode.audio()];
    this.howl.load();
    this.howl.once("load", () => { this.play(); });
  }

  play() {
    if (!this.isHowlReady()) return;
    requestAnimationFrame(this.step.bind(this));
    this.howl.play();
    this.playButton.addClass("is-playing").removeClass("is-paused is-loading");
  }

  pause() {
    if (!this.isHowlReady()) return;
    this.howl.pause();
    this.playButton.addClass("is-paused").removeClass("is-playing is-loading");
  }

  togglePlayPause() {
    if (!this.isHowlReady()) return;
    if (this.howl.playing()) {
      this.pause();
    } else {
      this.play();
    }
  }

  seekBy(to) {
    if (!this.isHowlReady()) return;
    const currentSeek = this.howl.seek() || 0;
    this.seek(currentSeek + to);
  }

  seek(to) {
    if (!this.isHowlReady()) return;
    if (to < 0) to = 0;
    this.howl.seek(to);
  }

  load(episode) {
    this.resetUI();
    this.playButton.addClass("is-loading");
    ajax(episode, {}, (error, data) => {
      this.episode = new Episode(data);
      this.loadUI();
      this.show();
      this.start();
    });
  }

  attachUI(selector) {
    this.container = u(selector);
    this.player = this.container.find(".js-player");
    this.art = this.container.find(".js-player-art");
    this.nowPlaying = this.container.find(".js-player-now-playing");
    this.title = this.container.find(".js-player-title");
    this.prevNumber = this.container.find(".js-player-prev-number");
    this.prevButton = this.container.find(".js-player-prev-button");
    this.nextNumber = this.container.find(".js-player-next-number");
    this.nextButton = this.container.find(".js-player-next-button");
    this.scrubber = this.container.find(".js-player-scrubber");
    this.track = this.container.find(".js-player-track");
    this.duration = this.container.find(".js-player-duration");
    this.current = this.container.find(".js-player-current");
    this.playButton = this.container.find(".js-player-play-button");
    this.backButton = this.container.find(".js-player-back-button");
    this.forwardButton = this.container.find(".js-player-forward-button");
  }

  attachEvents() {
    this.playButton.handle("click", () => { this.togglePlayPause(); });
    this.backButton.handle("click", () => { this.seekBy(-15); });
    this.forwardButton.handle("click", () => { this.seekBy(15); });
    this.scrubber.on("input", (event) => { this.scrub(event.target.value); });
    this.scrubber.on("change", (event) => { this.scrubEnd(event.target.value); });
  }

  loadUI() {
    this.art.attr("src", this.episode.art());
    this.nowPlaying.text("Now Playing: " + this.episode.nowPlaying());
    this.title.text(this.episode.title());
    this.duration.text(Episode.formatTime(this.episode.duration()));
    this.scrubber.attr("max", this.episode.duration());

    if (this.episode.hasPrev()) {
      this.prevNumber.text(this.episode.prevNumber());
      this.prevButton.data("play", this.episode.prevLocation());
    } else {
      this.prevNumber.text("");
      this.prevButton.first().removeAttribute("data-play");
    }

    if (this.episode.hasNext()) {
      this.nextNumber.text(this.episode.nextNumber());
      this.nextButton.data("play", this.episode.nextLocation());
    } else {
      this.nextNumber.text("");
      this.nextButton.first().removeAttribute("data-play");
    }
  }

  resetUI() {
    this.nowPlaying.text("Loading...");
    this.title.text("");
    this.current.text("0:00");
    this.duration.text("0:00");
    this.prevNumber.text("");
    this.prevButton.first().removeAttribute("data-play");
    this.nextNumber.text("");
    this.nextButton.first().removeAttribute("data-play");
    this.scrubber.first().value = 0;
    this.track.first().style.width = "0%";
  }

  step() {
    const seek = Math.round(this.howl.seek() || 0);
    const percentComplete = seek / this.episode.duration() * 100;

    if (!this.isScrubbing) {
      this.current.text(Episode.formatTime(seek));
      this.scrubber.first().value = seek;
      this.track.first().style.width = `${percentComplete}%`;
    }

    if (this.howl.playing()) {
      requestAnimationFrame(this.step.bind(this));
    }
  }

  scrub(to) {
    this.isScrubbing = true;
    const percentComplete = to / this.episode.duration() * 100;
    this.current.text(Episode.formatTime(to));
    this.track.first().style.width = `${percentComplete}%`;
  }

  scrubEnd(to) {
    this.isScrubbing = false;
    this.seek(to);
  }

  show() {
    this.player.addClass("podcast-player--is-active");
  }

  hide() {
   this.player.removeClass("podcast-player--is-active");
  }
}
