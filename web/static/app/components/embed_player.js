import { u } from "umbrellajs";
import Episode from "components/episode";
import Log from "components/log";
import ChangelogAudio from "components/audio";

export default class EmbedPlayer {
  constructor(selector) {
    this.audio = new ChangelogAudio();
    this.audioLoaded = false;
    this.attachUI(selector);
    this.attachEvents();
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
  }

  attachEvents() {
    this.playButton.handle("click", () => { if (this.isLoaded()) { this.togglePlayPause() } else { this.load() }; });
    this.navButton.handle("click", ()  => { this.toggleNav() });
    this.scrubber.on("input",  (event) => { if (this.isLoaded()) this.scrub(event.target.value); });
    this.scrubber.on("change", (event) => { if (this.isLoaded()) this.scrubEnd(event.target.value); });
  }

  load() {
    this.playButton.addClass("is-loading");
    // different from the onsite player:
    // these are both local since we have all info we need
    this.loadAudio();
    this.loadDetails();
  }

  loadAudio() {
    const audioUrl = this.playButton.attr("href");
    this.audio.load(audioUrl, () => {
      this.audioLoaded = true;
      this.play();
    });
  }

  loadDetails() {
    this.episode = new Episode({
      podcast: this.playButton.data("podcast"),
      title: this.playButton.data("title"),
      duration: this.playButton.data("title")
    });

    Log.track("Embed Play", {
      podcast: this.episode.podcastName(),
      episode: this.episode.title()
    });
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

  toggleNav() {
    this.nav.toggleClass("episode-player_nav--is-hidden");
  }

  step() {
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
}
