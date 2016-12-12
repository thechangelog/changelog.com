import { u, ajax } from "umbrellajs";
import Episode from "components/episode";
import Log from "components/log";
import ChangelogAudio from "components/audio";

export default class OnsitePlayer {
  constructor(selector) {
    // not using turbolinks:load event because we want this to run exactly once
    window.onload = () => {
      this.audio = new ChangelogAudio();
      this.detailsLoaded = false;
      this.audioLoaded = false;
      this.attachUI(selector);
      this.attachEvents();
      this.attachKeyboardShortcuts();
    }
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
    this.closeButton = this.container.find(".js-player-close");
    this.hideButton = this.container.find(".js-player-hide");
  }

  attachEvents() {
    this.playButton.handle("click", () => { this.togglePlayPause(); });
    this.backButton.handle("click", () => { this.seekBy(-15); });
    this.forwardButton.handle("click", () => { this.seekBy(15); });
    this.scrubber.on("input", (event) => { this.scrub(event.target.value); });
    this.scrubber.on("change", (event) => { this.scrubEnd(event.target.value); });
    this.closeButton.handle("click", () => { this.close(); });
    this.hideButton.handle("click", () => { this.hide(); });
  }

  attachKeyboardShortcuts() {
    u(document).on("keydown", (event) => {
      if (!this.isActive()) return;

      // 27 == escape
      if (event.keyCode == 27) {
        this.close();
      }

      // 32 == space bar
      if (event.keyCode == 32 && !u(event.target).is("input, textarea")) {
        event.preventDefault();
        this.togglePlayPause();
      }

      // 83 == s
      if (event.keyCode == 83 && !u(event.target).is("input, textarea")) {
        this.changeSpeed();
      }
    });
  }

  canPlay() {
    return this.audio.canPlay();
  }

  isActive() {
    return this.player.hasClass("podcast-player--is-active");
  }

  isPlaying() {
    return this.audio.playing();
  }

  play() {
    requestAnimationFrame(this.step.bind(this));
    this.audio.play();
    this.playButton.addClass("is-playing").removeClass("is-paused is-loading");
  }

  pause() {
    this.audio.pause();
    this.playButton.addClass("is-paused").removeClass("is-playing is-loading");
  }

  togglePlayPause() {
    if (this.isPlaying()) {
      this.pause();
    } else {
      this.play();
    }
  }

  changeSpeed() {
    this.audio.changeSpeed();
  }

  seekBy(to) {
    const currentSeek = this.audio.currentSeek() || 0;
    this.audio.seek(currentSeek + to);
  }

  // begins the process of playing the audio, fetching the details
  load(audioUrl, detailsUrl) {
    this.resetUI();
    this.playButton.addClass("is-loading");
    this.loadAudio(audioUrl);
    this.loadDetails(detailsUrl);
  }

  loadAudio(audioUrl) {
    this.audioLoaded = false;
    this.audio.load(audioUrl, () => {
      this.audioLoaded = true;
      this.play();
    });
  }

  loadDetails(detailsUrl) {
    this.detailsLoaded = false;
    ajax(detailsUrl, {}, (error, data) => {
      this.episode = new Episode(data);
      this.loadUI();
      this.detailsLoaded = true;
      this.show();
      Log.track("Play", {
        podcast: this.episode.podcastName(),
        episode: this.episode.title()
      });
    });
  }

  loadUI() {
    this.art.attr("src", this.episode.art());
    this.nowPlaying.text(this.episode.nowPlaying());
    this.title.text(this.episode.title());
    this.duration.text(Episode.formatTime(this.episode.duration()));
    this.scrubber.attr("max", this.episode.duration());

    if (this.episode.hasPrev()) {
      this.prevNumber.text(this.episode.prevNumber());
      this.prevButton.attr("title", "Listen to " + this.episode.prevTitle());
      this.prevButton.attr("href", this.episode.prevAudio());
      this.prevButton.data("play", this.episode.prevLocation());
    } else {
      this.resetPrevUI();
    }

    if (this.episode.hasNext()) {
      this.nextNumber.text(this.episode.nextNumber());
      this.nextButton.attr("title", "Listen to " + this.episode.nextTitle());
      this.nextButton.attr("href", this.episode.nextAudio());
      this.nextButton.data("play", this.episode.nextLocation());
    } else {
      this.resetNextUI();
    }
  }

  resetUI() {
    this.nowPlaying.text("Loading...");
    this.title.text("");
    this.current.text("0:00");
    this.duration.text("0:00");
    this.resetPrevUI();
    this.resetNextUI();
    this.scrubber.first().value = 0;
    this.track.first().style.width = "0%";
  }

  resetPrevUI() {
    this.prevNumber.text("");
    this.prevButton.first().removeAttribute("href");
    this.prevButton.first().removeAttribute("data-play");
  }

  resetNextUI() {
    this.nextNumber.text("");
    this.nextButton.first().removeAttribute("href");
    this.nextButton.first().removeAttribute("data-play");
  }

  step() {
    if (!this.detailsLoaded) {
      // wait for it...
      requestAnimationFrame(this.step.bind(this));
      return;
    }

    const seek = Math.round(this.audio.currentSeek() || 0);
    const percentComplete = seek / this.episode.duration() * 100;

    if (!this.isScrubbing) {
      this.current.text(Episode.formatTime(seek));
      this.scrubber.first().value = seek;
      this.track.first().style.width = `${percentComplete}%`;
    }

    if (this.isPlaying()) {
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
    this.audio.seek(to, () => {
      this.playButton.addClass("is-loading");
    }, () => {
      this.playButton.removeClass("is-loading");
    });
  }

  show() {
    this.player.addClass("podcast-player--is-active").removeClass("podcast-player--is-hidden");
  }

  hide() {
    this.player.toggleClass("podcast-player--is-hidden");
  }

  close() {
    this.pause();
    this.player.removeClass("podcast-player--is-active");
  }
}
