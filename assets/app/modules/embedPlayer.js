import { u } from "umbrellajs";
import Episode from "modules/episode";
import Log from "modules/log";
import ChangelogAudio from "modules/audio";
import Embedly from "modules/embedly";
import gup from "../../shared/gup";

export default class EmbedPlayer {
  constructor(selector) {
    this.audio = new ChangelogAudio();
    this.audioLoaded = false;
    this.attachUI(selector);
    this.attachEvents();
    this.loadDetails();
    this.embedly = new Embedly(this);
    this.tracked = {25: false, 50: false, 75: false, 100: false};
  }

  attachUI(selector) {
    this.container = u(selector);
    this.player = this.container.find(".js-player");
    this.nav = this.container.find(".js-nav");
    this.scrubber = this.container.find(".js-player-scrubber");
    this.track = this.container.find(".js-player-track");
    this.duration = this.container.find(".js-player-duration");
    this.current = this.container.find(".js-player-current");
    this.playButton = this.container.find(".js-player-play-button");
    this.navButton = this.container.find(".js-nav-toggle-button");
    this.listenLinks = this.container.find(".js-listen-link");
    this.listenHref = this.listenLinks.attr("href");
  }

  attachEvents() {
    this.playButton.handle("click", () => { this.isLoaded() ? this.togglePlayPause() : this.load(); });
    this.navButton.handle("click", ()  => { this.toggleNav(); });
    this.listenLinks.on("click", () => { this.pause(); });
    this.scrubber.on("input",  (event) => { if (this.isLoaded()) this.scrub(event.target.value); });
    this.scrubber.on("change", (event) => { if (this.isLoaded()) this.scrubEnd(event.target.value); });
    this.audio.onEnd((event) => { this.embedly.emit("ended"); });
    this.audio.onTimeUpdate((event) => { this.trackTime(); });
  }

  load() {
    this.player.addClass("is-loading");
    this.loadAudio();
  }

  loadAudio() {
    this.audio.load(this.episode.audio(), () => {
      this.audioLoaded = true;
      this.log("Play");

      this.play();
    });
  }

  loadDetails() {
    this.episode = new Episode({
      podcast: this.playButton.data("podcast"),
      title: this.playButton.data("title"),
      duration: this.playButton.data("duration"),
      audio_url: this.playButton.attr("href")
    });
  }

  log(action) {
    let source = (gup("source") == "twitter") ? "Twitter" : "Embed";
    Log.track(`${source} Player`, action, this.episode.title());
  }

  isPlaying() {
    return this.audio.playing();
  }

  isLoaded() {
    return this.audioLoaded;
  }

  play() {
    requestAnimationFrame(this.step.bind(this));
    this.audio.play();
    this.player.addClass("is-playing").removeClass("is-paused is-loading");
    this.embedly.emit("play");
  }

  pause() {
    this.audio.pause();
    this.player.addClass("is-paused").removeClass("is-playing is-loading");
    this.embedly.emit("pause");
  }

  togglePlayPause() {
    if (this.isPlaying()) {
      this.pause();
    } else {
      this.play();
    }
  }

  toggleNav() {
    this.player.toggleClass("nav-open");
  }

  trackTime() {
    this.embedly.emit("timeupdate", {seconds: this.currentTime(), duration: this.episodeDuration()});
    this.listenLinks.attr("href", `${this.listenHref}#t=${this.currentTime()}`);
    let complete = this.percentComplete();

    for (var percent in this.tracked) {
      if (complete >= percent && !this.tracked[percent]) {
        this.log(`${percent}% Played`);
        this.tracked[percent] = true;
      }
    }
  }

  loop(bool) {
    this.audio.loop(bool);
  }

  willLoop() {
    return this.audio.willLoop();
  }

  mute() {
    this.audio.mute();
  }

  unmute() {
    this.audio.unmute();
  }

  isMuted() {
    return this.audio.isMuted();
  }

  episodeDuration() {
    return this.episode.duration();
  }

  currentTime() {
    return Math.round(this.audio.currentSeek() || 0);
  }

  percentComplete(asOfTime) {
    return asOfTime / this.episodeDuration() * 100;
  }

  step() {
    if (!this.isScrubbing) {
      let time = this.currentTime();
      this.current.text(Episode.formatTime(time));
      this.scrubber.first().value = time;
      this.track.first().style.width = `${this.percentComplete(time)}%`;
    }

    if (this.isPlaying()) {
      requestAnimationFrame(this.step.bind(this));
    }
  }

  scrub(to) {
    this.isScrubbing = true;
    this.current.text(Episode.formatTime(to));
    this.track.first().style.width = `${this.percentComplete(to)}%`;
  }

  scrubEnd(to) {
    this.isScrubbing = false;
    this.audio.seek(to, () => {
      this.player.addClass("is-loading");
    }, () => {
      this.player.removeClass("is-loading");
    });
  }
}
