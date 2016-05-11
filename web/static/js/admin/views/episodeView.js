import SearchWidget from "../components/searchWidget"
import ListWidget from "../components/listWidget"

export default class EpisodeView {
  new() {
    let $hostWidget = new SearchWidget("person", "episode", "hosts");
    let $guestWidget = new SearchWidget("person", "episode", "guests");
    let $sponsorWidget = new SearchWidget("sponsor", "episode", "sponsors");
    let $channelWidget = new SearchWidget("channel", "episode", "channels");
    let $linkWidget = new ListWidget("episode", "links");
  }

  edit() {
    this.new();
  }
}
