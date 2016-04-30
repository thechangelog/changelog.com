import SearchWidget from "../components/searchWidget"

export default class EpisodeView {
  new() {
    let $hostWidget = new SearchWidget("person", "episode", "hosts");
    let $guestWidget = new SearchWidget("person", "episode", "guests");
    let $sponsorWidget = new SearchWidget("sponsor", "episode", "sponsors");
    let $topicWidget = new SearchWidget("topic", "episode", "topics");
  }

  edit() {
    this.new();
  }
}
