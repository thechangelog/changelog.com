import PersonSearchWidget from "../components/personSearchWidget"

export default class PodcastView {
  new() {
    let $hostWidget = new PersonSearchWidget("podcast", "hosts")
  }

  edit() {
    this.new()
  }
}
