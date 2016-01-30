import SearchWidget from "../components/searchWidget"

export default class PodcastView {
  new() {
    let $hostWidget = new PersonSearchWidget("person", "podcast", "hosts")
  }

  edit() {
    this.new()
  }
}
