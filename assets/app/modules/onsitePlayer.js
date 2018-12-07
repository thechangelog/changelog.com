import { u, ajax } from "umbrellajs";
import Episode from "modules/episode";
import Log from "modules/log";
import ChangelogAudio from "modules/audio";
import PlayButton from "modules/playButton";

export default class OnsitePlayer {
  constructor(selector) {
    this.selector = selector;
    this.isAttached = false;
    this.tracked = {25: false, 50: false, 75: false, 100: false};
  }

  attach() {
    if (this.isAttached) return;

    this.audio = new ChangelogAudio();
    this.detailsLoaded = false;
    this.audioLoaded = false;
    this.playButtons = new PlayButton();
    this.currentlyLoaded = "";
    this.deepLink = 0;
    this.attachUI();
    this.attachEvents();
    this.attachKeyboardShortcuts();
    this.isAttached = true;
  }

  attachUI() {
    this.container = u(this.selector);
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
    this.playButton.handle("click", _ => { this.togglePlayPause(); });
    this.backButton.handle("click", _ => { this.seekBy(-15); });
    this.forwardButton.handle("click", _ => { this.seekBy(15); });
    this.scrubber.on("input", event => { this.scrub(event.target.value); });
    this.scrubber.on("change", event => { this.scrubEnd(event.target.value); });
    this.closeButton.handle("click", _ => { this.close(); });
    this.hideButton.handle("click", _ => { this.hide(); });
    this.audio.onTimeUpdate(event => { this.trackTime(); });
    this.audio.onPlay(event => { this.playUI(); });
    this.audio.onPause(event => { this.pauseUI(); });
  }

  attachKeyboardShortcuts() {
    u(document).on("keydown", event => {
      if (!this.isActive()) return;
      if (u(event.target).is("input, textarea")) return;

      switch (event.keyCode) {
        case 27: // escape
          this.close();
          break;
        case 32: // space bar
          event.preventDefault();
          this.togglePlayPause();
          break;
        case 83: // s
          this.changeSpeed();
          break;
        default:
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
    return !!this.audio && this.audio.playing();
  }

  play() {
    requestAnimationFrame(this.step.bind(this));

    this.audio.play().then(_ => {
      this.playUI();
    }).catch(error => {
      this.pauseUI();
      console.log("failed to play", error);
    });
  }

  playUI() {
    this.playButtons.play();
    this.playButton.addClass("is-playing").removeClass("is-paused is-loading");
    if (!this.isActive()) this.show();
  }

  pause() {
    this.audio.pause();
    this.pauseUI();
  }

  pauseUI() {
    this.playButtons.pause();
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
    this.step();
  }

  // begins the process of playing the audio, fetching the details
  load(audioUrl, detailsUrl, andThen) {
    this.resetUI();
    this.playButton.addClass("is-loading");
    this.playButton.attr("data-loaded", detailsUrl);
    this.currentlyLoaded = detailsUrl;
    this.playButtons.belongsTo(this.currentlyLoaded);
    this.loadAudio(audioUrl, andThen);
    this.loadDetails(detailsUrl);
  }

  loadAudio(audioUrl, andThen) {
    this.audioLoaded = false;
    this.audio.load(audioUrl, _ => {
      this.audioLoaded = true;
      this.play();
      if (andThen) andThen();
    });
  }

  loadDetails(detailsUrl) {
    this.detailsLoaded = false;
    ajax(detailsUrl, {}, (error, data) => {
      this.episode = new Episode(data);
      this.loadUI();
      this.detailsLoaded = true;
      this.show();
      this.log("Play");
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

  log(action) {
    Log.track("Onsite Player", action, this.episode.title());
  }

  resetUI() {
    this.nowPlaying.text("Loading...");
    this.title.text("");
    this.current.text("0:00");
    this.duration.text("0:00");
    this.playButton.first().removeAttribute("data-loaded");
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

  currentTime() {
    return Math.round(this.audio.currentSeek() || 0);
  }

  percentComplete(asOfTime) {
    if (!this.detailsLoaded) return 0;
    return asOfTime / this.episode.duration() * 100;
  }

  step() {
    if (!this.detailsLoaded) {
      // wait for it...
      requestAnimationFrame(this.step.bind(this));
      return;
    }

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
    this.audio.seek(to, _ => {
      this.playButton.addClass("is-loading");
    }, _ => {
      this.playButton.removeClass("is-loading");
    });
  }

  show() {
    u('body').addClass('player-open');
    this.player.addClass("podcast-player--is-active").removeClass("podcast-player--is-hidden");
  }

  hide() {
    u('body').toggleClass('player-open');
    this.player.toggleClass("podcast-player--is-hidden");
  }

  close() {
    this.pause();
    u('body').removeClass('player-open');
    this.player.removeClass("podcast-player--is-active");
  }

  trackTime() {
    let complete = this.percentComplete(this.currentTime());

    for (var percent in this.tracked) {
      if (complete >= percent && !this.tracked[percent]) {
        this.log(`${percent}% Played`);
        this.tracked[percent] = true;
      }
    }
  }
}
