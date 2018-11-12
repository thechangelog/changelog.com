import { u } from "umbrellajs";
import Log from "modules/log";
import Episode from "modules/episode";
import ChangelogAudio from "modules/audio";

export default class MiniPlayer {
  constructor(container) {
    this.container = u(container);
    this.audio = new ChangelogAudio();
    this.title = this.container.data("title");
    this.audioUrl = this.container.data("audio");
    this.duration = this.container.data("duration");
    this.resetAudio();
    this.attachUI();
    this.attachEvents();
    container.player = this;
  }

  attachUI() {
    this.scrubber = this.container.find(".js-player-scrubber");
    this.track = this.container.find(".js-player-track");
    this.current = this.container.find(".js-player-current");
    this.playButton = this.container.find(".js-player-play-button");
  }

  attachEvents() {
    this.playButton.handle("click", () => { this.audioLoaded ? this.togglePlayPause() : this.load(); });
    this.scrubber.on("input", (event) => { this.scrub(event.target.value); });
    this.scrubber.on("change", (event) => { this.scrubEnd(event.target.value); });
    this.audio.onTimeUpdate((event) => { this.trackTime(); });
    this.audio.onEnd((event) => { this.reset(); });
    u("body").on("mini-player-play", (event, player) => { this.pauseForOther(player); });
  }

  canPlay() {
    return this.audio.canPlay();
  }

  isPlaying() {
    return !!this.audio && this.audio.playing();
  }

  play() {
    requestAnimationFrame(this.step.bind(this));
    this.playButton.addClass("is-playing").removeClass("is-paused is-loading");
    this.audio.play();
    u("body").trigger("mini-player-play", this);
  }

  pause() {
    this.playButton.addClass("is-paused").removeClass("is-playing is-loading");
    this.audio.pause();
  }

  pauseForOther(player) {
    if (this.isPlaying() && player != this) this.pause();
  }

  togglePlayPause() {
    if (this.isPlaying()) {
      this.pause();
    } else {
      this.play();
    }
  }

  seekBy(to) {
    const currentSeek = this.audio.currentSeek() || 0;
    this.audio.seek(currentSeek + to);
  }

  load() {
    this.playButton.addClass("is-loading");
    this.audio.load(this.audioUrl, () => {
      this.audioLoaded = true;
      this.log("Play");
      this.play();
    });
  }

  log(action) {
    Log.track("Mini Player", action, this.title);
  }

  reset() {
    this.resetAudio();
    this.resetUI();
  }

  resetAudio() {
    this.audioLoaded = false;
    this.tracked = { 25: false, 50: false, 75: false, 100: false };
  }

  resetUI() {
    this.current.text("0:00");
    this.scrubber.first().value = 0;
    this.track.first().style.width = "0%";
    this.playButton.removeClass("is-playing is-loading");
  }

  currentTime() {
    return Math.round(this.audio.currentSeek() || 0);
  }

  percentComplete() {
    return this.currentTime() / this.duration * 100;
  }

  step() {
    if (this.audioLoaded && !this.isScrubbing) {
      this.current.text(Episode.formatTime(this.currentTime()));
      this.scrubber.first().value = this.currentTime();
      this.track.first().style.width = `${this.percentComplete()}%`;
    }

    if (this.isPlaying()) requestAnimationFrame(this.step.bind(this));
  }

  scrub(to) {
    this.isScrubbing = true;
    this.current.text(Episode.formatTime(to));
    this.track.first().style.width = `${this.percentComplete()}%`;
  }

  scrubEnd(to) {
    this.isScrubbing = false;
    this.audio.seek(to, () => {
      this.playButton.addClass("is-loading");
    }, () => {
      this.playButton.removeClass("is-loading");
    });
  }

  trackTime() {
    let complete = this.percentComplete();

    for (var percent in this.tracked) {
      if (complete >= percent && !this.tracked[percent]) {
        this.log(`${percent}% Played`);
        this.tracked[percent] = true;
      }
    }
  }
}
