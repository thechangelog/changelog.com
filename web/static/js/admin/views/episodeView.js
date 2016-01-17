import PersonSearchWidget from "../components/personSearchWidget"

export default class EpisodeView {
  new() {
    let $hostWidget = new PersonSearchWidget("episode", "hosts")
  }

  edit() {
    this.new()
  }
}
