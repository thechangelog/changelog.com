import PersonSearchWidget from "../components/personSearchWidget"

export default class EpisodeView {
  new() {
    let $hostWidget = new PersonSearchWidget("episode", "hosts")
    let $guestWidget = new PersonSearchWidget("episode", "guests")
  }

  edit() {
    this.new()
  }
}
