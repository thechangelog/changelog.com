import SearchWidget from "components/searchWidget";

export default class PodcastView {
  new() {
    let $hostWidget = new SearchWidget("person", "podcast", "hosts")
  }

  edit() {
    this.new()
  }
}
