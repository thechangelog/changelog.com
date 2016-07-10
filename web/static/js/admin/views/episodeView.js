import SearchWidget from "../components/searchWidget";

export default class EpisodeView {
  new() {
    let $hostWidget = new SearchWidget("person", "episode", "hosts");
    let $guestWidget = new SearchWidget("person", "episode", "guests");
    let $sponsorWidget = new SearchWidget("sponsor", "episode", "sponsors");
    let $channelWidget = new SearchWidget("channel", "episode", "channels");
  }

  edit() {
    this.new();
  }
}
