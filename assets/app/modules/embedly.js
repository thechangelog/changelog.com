export default class Embedly {
  constructor(player) {
    this.origin = document.referrer.split("/").slice(0,3).join("/");
    this.player = player;
    this.listeners = {};
    this.events = ["play", "pause", "timeupdate", "ended"];
    this.methods = ["play", "pause", "getPaused", "setLoop", "getLoop",
      "getVolume", "setVolume", "mute", "unmute", "getMuted", "getDuration",
      "setCurrentTime", "getCurrentTime", "addEventListener",
      "removeEventListener"];

    window.addEventListener("message", (event) => { this.receive(event); });
    window.addEventListener("load", (event) => { this.sendHeight(); })
    window.addEventListener("resize", (event) => { this.sendHeight(); })

    this.send("ready", {
      src: window.location.toString(),
      events: this.events,
      methods: this.methods
    });
  }

  send(event, value, listener) {
    let message = {
      context: "player.js",
      version: "0.0.11",
      event: event
    }
    let origin = this.origin == "" ? "*" : this.origin;

    if (value != undefined) {
      message.value = value;
    }

    if (listener != undefined) {
      message.listener = listener;
    }

    window.parent.postMessage(JSON.stringify(message), origin);
  }

  sendHeight() {
    let message = {
      src: window.location.toString(),
      context: "iframe.resize",
      height: 220
    }
    let origin = "*";

    window.parent.postMessage(JSON.stringify(message), origin);
  }

  receive(event) {
    const message = JSON.parse(event.data);
    if (message.context !== "player.js") return false;
    if (!message.method) return false;

    switch (message.method) {
      case "play":
        this.player.isLoaded() ? this.player.play() : this.player.load();
        break;
      case "pause":
        this.player.pause();
        break;
      case "getPaused":
        this.send("getPaused", !this.player.isPlaying(), message.listener);
        break;
      case "setLoop":
        this.player.loop(message.value);
        break;
      case "getLoop":
        this.send("getLoop", this.player.willLoop(), message.listener);
        break;
      case "getVolume":
        this.send("getVolume", (this.player.audio.currentVolume() * 100), message.listener);
        break;
      case "setVolume":
        this.player.audio.setVolume(message.value);
        break;
      case "mute":
        this.player.mute();
        break;
      case "unmute":
        this.player.unmute();
        break;
      case "getMuted":
        this.send("getMuted", this.player.isMuted(), message.listener);
        break;
      case "getDuration":
        this.send("getDuration", this.player.episodeDuration(), message.listener);
        break;
      case "setCurrentTime":
        this.player.scrubEnd(message.value);
        break;
      case "getCurrentTime":
        this.send("getCurrentTime", this.player.currentTime(), message.listener);
        break;
      case "addEventListener":
        this.addListener(message.value, message.listener);
        break;
      case "removeEventListener":
        this.removeListener(message.value, message.listener);
        break;
      default:
        console.log("method not supported", message.method);
      }
  }

  addListener(event, listener) {
    if (this.listeners.hasOwnProperty(event)) {
      if (this.listeners[event].indexOf(listener) == -1) {
        this.listeners[event].push(listener);
      }
    } else {
      this.listeners[event] = [listener];
    }
  }

  removeListener(event, listener) {
    if (this.listeners.hasOwnProperty(event)) {
      let index = this.listeners[event].indexOf(listener);

      if (index > -1) {
        this.listeners[event].splice(index, 1);
      }

      if (this.listeners[event].length == 0) {
        delete this.listeners[event];
      }
    }
  }

  emit(event, value) {
    if (!this.listeners.hasOwnProperty(event)) return false;

    for (var i = 0; i < this.listeners[event].length; i++) {
      var listener = this.listeners[event][i];
      this.send(event, value, listener);
    }
  }
}
