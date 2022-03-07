export default class ChangelogAudio {
  constructor() {
    if (typeof Audio === "undefined") {
      this.hasAudio = false;
      return;
    } else {
      this.hasAudio = true;
    }

    this.audio = new Audio();
  }

  load(file, callback) {
    if (callback) this.runOnce("canplaythrough", callback);

    this.audio.type = "audio/mpeg";
    this.audio.src = file;
    this.audio.load();
  }

  onPlay(callback) {
    this.run("play", callback);
  }

  onPause(callback) {
   this.run("pause", callback);
  }

  onTimeUpdate(callback) {
    this.run("timeupdate", callback);
  }

  onEnd(callback) {
    this.run("ended", callback);
  }

  canPlay() {
    return this.hasAudio;
  }

  play() {
    return this.audio.play();
  }

  pause() {
    if (!this.playing()) return;
    return this.audio.pause();
  }

  playing() {
    return this.audio.duration > 0 && !this.audio.paused;
  }

  willLoop() {
    return this.audio.loop;
  }

  loop(bool) {
    this.audio.loop = bool;
  }

  isMuted() {
    return this.audio.muted;
  }

  mute() {
    this.audio.muted = true;
  }

  unmute() {
    this.audio.muted = false;
  }

  currentSpeed() {
    return this.audio.playbackRate;
  }

  setSpeed(to) {
    if (!to) return false;
    this.audio.playbackRate = to;
  }

  currentTime() {
    return Math.round(this.audio.currentTime || 0);
  }

  setTime(to) {
    this.audio.currentTime = to;
  }

  currentVolume() {
    return Math.round(this.audio.volume * 10) / 10;
  }

  setVolume(value) {
    if (value < 0) return false;
    if (value > 1) return false;
    this.audio.volume = value;
  }

  seek(to, before, after) {
    to = parseInt(to, 10);
    if (to < 0) to = 0;

    if (before) this.runOnce("seeking", before);
    if (after) this.runOnce("seeked", after);

    this.setTime(to);
  }

  changeSpeed() {
    let current = this.currentSpeed();

    if (current == 2.0) {
      this.setSpeed(1);
    } else {
      this.setSpeed(current + 0.25);
    }

    return this.currentSpeed();
}

  run(eventName, fn) {
    this.audio.addEventListener(eventName, fn);
  }

  runOnce(eventName, fn) {
    let listener = () => {
      fn.call();
      this.audio.removeEventListener(eventName, listener);
    }

    this.audio.addEventListener(eventName, listener);
  }
}
