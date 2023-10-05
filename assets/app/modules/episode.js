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

  chapterList() {
    return this.ep.chapters;
  }

  duration() {
    return parseInt(this.ep.duration, 10);
  }

  hasChapters() {
    return !!this.ep.chapters.length;
  }

  id() {
    return this.ep.id;
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
