import { u, ajax } from "umbrellajs";
import Episode from "modules/episode";
import Log from "modules/log";
import ChangelogAudio from "modules/audio";
import PlayButton from "modules/playButton";
import parseTime from "../../shared/parseTime";

export default class OnsitePlayer {
  constructor(selector) {
    this.selector = selector;
    this.isAttached = false;
    this.tracked = {25: false, 50: false, 75: false, 100: false};
    this.state = {speed: 1, volume: 1, loaded: null};
  }

  attach() {
    if (this.isAttached) return;

    this.audio = new ChangelogAudio();
    this.playButtons = new PlayButton();
    this.attachUI();
    this.attachEvents();
    this.attachKeyboardShortcuts();
    this.isAttached = true;
    this.restoreState();
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
    this.currentInput = this.container.find(".js-player-current-input");
    this.playButton = this.container.find(".js-player-play-button");
    this.backButton = this.container.find(".js-player-back-button");
    this.forwardButton = this.container.find(".js-player-forward-button");
    this.copyUrlButton = this.container.find(".js-player-copy-url");
    this.closeButton = this.container.find(".js-player-close");
    this.hideButton = this.container.find(".js-player-hide");
    this.speedButton = this.container.find(".js-player-speed");
    this.chapterSelect = this.container.find(".js-chapter-select");
  }

  attachEvents() {
    this.playButton.handle("click", _ => { this.togglePlayPause(); });
    this.backButton.handle("click", _ => { this.seekBy(-15); });
    this.forwardButton.handle("click", _ => { this.seekBy(15); });
    this.scrubber.on("input", event => { this.scrub(event.target.value); });
    this.scrubber.on("change", event => { this.scrubEnd(event.target.value); });
    this.copyUrlButton.on("click", event => { this.copyUrlToClipboard(event); });
    this.closeButton.handle("click", _ => { this.close(); });
    this.hideButton.handle("click", _ => { this.hide(); });
    this.speedButton.handle("click", _ => { this.changeSpeed(); });
    this.current.handle("click", _ => { this.focusCurrentInput(); });
    this.currentInput.handle("focusout", _ => { this.updateCurrent(); });
    this.currentInput.on("keydown", event => { this.keyCurrent(event); });
    this.audio.onTimeUpdate(event => { this.updateCopyUrlTime(); this.trackTime(); });
    this.audio.onPlay(event => { this.playUI(); });
    this.audio.onPause(event => { this.pauseUI(); });
    this.chapterSelect.handle("change", event => { this.changeChapter(event.target.value); });
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
        case 187: // +
          this.changeVolumeBy(0.1);
          break;
        case 189: // -
          this.changeVolumeBy(-0.1);
          break;
        default:
      }
    });
  }

  canPlay() {
    return this.audio.canPlay();
  }

  isActive() {
    return this.player.hasClass("podcast_player--is-active");
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

  focusCurrentInput() {
    let input = this.currentInput.first();
    let width = "45px";

    if (this.episode.duration() > 3600) {
      width = "58px";
    }

    this.current.addClass("is-hidden");

    this.currentInput
      .attr("value", this.current.text())
      .attr("style", `width: ${width};`)
      .removeClass("is-hidden")

    this.pause();

    input.value = this.current.text();
    input.focus();
    input.select();
  }

  blurCurrentInput() {
    this.currentInput.addClass("is-hidden");
    this.current.removeClass("is-hidden");
  }

  keyCurrent(event) {
    if (event.keyCode == 13) { // enter
      event.preventDefault();
      this.currentInput.trigger("focusout"); // triggers update
    }

    if (event.keyCode == 27) { // escape
      this.blurCurrentInput();
      event.stopPropagation();
    }
  }

  updateCurrent() {
    let newTime = parseTime(this.currentInput.first().value);

    if (newTime > this.episode.duration()) {
      newTime = this.episode.duration() - 10;
    }

    this.seekTo(newTime);
    this.blurCurrentInput();
    this.play();
  }

  changeSpeed() {
    let newSpeed = this.audio.changeSpeed();
    this.setState("speed", newSpeed);
    this.speedButton.html(`[${newSpeed }X]`);
  }

  changeVolumeBy(to) {
    let newVolume = this.audio.currentVolume() + to;
    this.setState("volume", newVolume);
    this.audio.setVolume(this.state.volume);
  }

  seekTo(to) {
    this.audio.seek(to);
    this.step();
  }

  seekBy(offset) {
    let currentTime = this.audio.currentTime() || 0;
    this.seekTo(currentTime + offset);
  }

  // begins the process of fetching details, playing audio
  load(detailsUrl, andThen) {
    this.episode = null;
    this.state.loaded = null;
    this.resetUI();
    this.playButton.addClass("is-loading");
    this.playButton.attr("data-loaded", detailsUrl);
    this.playButtons.belongsTo(detailsUrl);

    ajax(detailsUrl, {}, (error, data) => {
      this.state.loaded = detailsUrl;
      this.episode = new Episode(data);
      this.loadUI();
      this.show();

      this.audio.load(this.episode.audio(), _ => {
        let resumeSpeed = this.state.speed;
        if (resumeSpeed) {
          this.audio.setSpeed(resumeSpeed);
        }

        let resumeTime = this.state[this.state.loaded];
        if (resumeTime) {
          this.audio.setTime(resumeTime);
          this.updatePlayTime(resumeTime);
          this.updateChapter(resumeTime);
        }

        let resumeVolume = this.state.volume;
        if (resumeVolume) {
          this.audio.setVolume(resumeVolume);
        }

        this.play();
        this.log("Play");

        if (andThen) andThen();
      });
    });
  }

  isLoaded(detailsUrl) {
    return this.state.loaded == detailsUrl;
  }

  loadUI() {
    this.art.attr("src", this.episode.art());
    this.nowPlaying.text(this.episode.nowPlaying());
    this.title.text(this.episode.title());
    this.duration.text(Episode.formatTime(this.episode.duration()));
    this.scrubber.attr("max", this.episode.duration());
    this.speedButton.html(`[${this.state.speed}X]`);

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

    if (this.episode.hasChapters()) {
      let options = "";
      let chapters = this.episode.chapterList();

      for (var i = 0; i < chapters.length; i++) {
        options += `<option value="${chapters[i].number}">${chapters[i].number}: ${chapters[i].title}</option>`
      }

      this.chapterSelect.html(options);
      this.chapterSelect.removeClass("is-hidden");
    }
  }

  log(action) {
    Log.track("Onsite Player", {action: action, episode: this.episode.title()});
  }

  resetUI() {
    this.nowPlaying.text("Loading...");
    this.title.text("");
    this.current.text("0:00");
    this.duration.text("0:00");
    this.playButton.first().removeAttribute("data-loaded");
    this.copyUrlButton.attr("href", "");
    this.resetPrevUI();
    this.resetNextUI();
    this.scrubber.first().value = 0;
    this.track.first().style.width = "0%";
    this.chapterSelect.html("");
    this.chapterSelect.addClass("is-hidden");
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

  setState(key, value) {
    this.state[key] = value;
    localStorage.setItem("player", JSON.stringify(this.state));
  }

  restoreState() {
    let state = JSON.parse(localStorage.getItem("player"));

    if (state) {
      this.state = state;

      if (this.state.loaded) {
        this.load(this.state.loaded);
      }
    }
  }

  percentComplete(asOfTime) {
    if (!this.state.loaded) return 0;
    return asOfTime / this.episode.duration() * 100;
  }

  step() {
    if (!this.state.loaded) {
      // wait for it...
      requestAnimationFrame(this.step.bind(this));
      return;
    }

    if (!this.isScrubbing) {
      let newTime = this.audio.currentTime();
      let prevTime = this.state[this.state.loaded];

      if (newTime != prevTime) {
        this.updatePlayTime(newTime);
        this.updateChapter(newTime);
        this.setState(this.state.loaded, newTime);
      }
    }

    if (this.isPlaying()) {
      requestAnimationFrame(this.step.bind(this));
    }
  }

  changeChapter(chapterNumber) {
    let newChapter = this.episode.chapterList().find(chapter => {
      return chapter.number == chapterNumber
    });

    if (newChapter) {
      this.scrubEnd(newChapter.startTime);
    }
  }

  updateChapter(newTime) {
    if (this.episode.hasChapters()) {
      let currentChapter = this.episode.chapterList().find(chapter => {
        return chapter.startTime <= newTime && chapter.endTime >= newTime
      })

      if (currentChapter) {
        this.chapterSelect.first().value = currentChapter.number;
      }
    }
  }

  updatePlayTime(newTime) {
    this.current.text(Episode.formatTime(newTime));
    this.scrubber.first().value = newTime;
    this.track.first().style.width = `${this.percentComplete(newTime)}%`;
  }

  scrub(to) {
    this.isScrubbing = true;
    this.current.text(Episode.formatTime(to));
    this.track.first().style.width = `${this.percentComplete(to)}%`;
  }

  scrubEnd(to) {
    this.isScrubbing = false;
    this.setState(this.state.loaded, to);
    this.updatePlayTime(to);

    this.audio.seek(to, _ => {
      this.playButton.addClass("is-loading");
    }, _ => {
      this.playButton.removeClass("is-loading");
    });
  }

  show() {
    u("body").addClass("player-open");
    this.player.addClass("podcast_player--is-active").removeClass("podcast_player--is-hidden");
  }

  hide() {
    u("body").toggleClass("player-open");
    this.player.toggleClass("podcast_player--is-hidden");
  }

  close() {
    this.pause();
    this.setState("loaded", null);
    u("body").removeClass("player-open");
    this.player.removeClass("podcast_player--is-active");
  }

  copyUrlToClipboard(event) {
    if (!"execCommand" in document) return event;

    event.preventDefault();
    event.stopPropagation();

    this.copyUrlButton.addClass("is-copying");

    let url = u(".js-player-current-url");
    url.attr("type", "text");
    url.attr("value", this.copyUrlButton.attr("href"));
    url.first().select();
    document.execCommand("copy");
    url.attr("type", "hidden");

    setTimeout(_ => {
      this.copyUrlButton.removeClass("is-copying");
    }, 400);
  }

  trackTime() {
    let complete = this.percentComplete(this.audio.currentTime());

    for (var percent in this.tracked) {
      if (complete >= percent && !this.tracked[percent]) {
        this.log(`${percent}% Played`);
        this.tracked[percent] = true;
      }
    }
  }

  updateCopyUrlTime() {
    let time = this.audio.currentTime();
    if (this.episode && time > 0) {
      this.copyUrlButton.attr("href", this.episode.shareUrlWithTs(time));
    }
  }
}
