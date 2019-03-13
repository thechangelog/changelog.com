export default class Episode {
  static formatTime(secs) {
    let hours = Math.floor(secs / 3600) || 0;
    let minutes = Math.floor(secs / 60) || 0;
    let seconds = (secs - minutes * 60) || 0;
    let formatted = "";

    if (hours > 0) {
      minutes = (minutes - hours * 60) || 0;
      formatted += `${hours}:${(minutes < 10 ? "0" : "")}`;
    }

    formatted += `${minutes}:${(seconds < 10 ? "0" : "")}${seconds}`;

    return formatted;
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

  audioFile() {
    let parts = this.audio().split("/");
    return parts[parts.length - 1];
  }

  duration() {
    return parseInt(this.ep.duration, 10);
  }

  hasPrev() {
    return !!this.prev;
  }

  hasNext() {
    return !!this.next;
  }

  nextNumber() {
    return `#${this.next.number}`;
  }

  nextTitle() {
    return this.next.title;
  }

  nextLocation() {
    return this.next.location;
  }

  nextAudio() {
   return this.next.audio_url;
  }

  nowPlaying() {
    if (this.ep.number) {
      return `${this.podcastName()} #${this.ep.number}`
    } else {
      return this.podcastName();
    }
  }

  podcastName() {
    return this.ep.podcast;
  }

  prevNumber() {
    return `#${this.prev.number}`;
  }

  prevTitle() {
    return this.prev.title;
  }

  prevAudio() {
   return this.prev.audio_url;
  }

  prevLocation() {
    return this.prev.location;
  }

  shareUrl() {
    return this.ep.share_url;
  }

  shareUrlWithTs(asOfTime) {
    return `${this.shareUrl()}#t=${Episode.formatTime(asOfTime)}`;
  }

  title() {
    return this.ep.title;
  }
}
