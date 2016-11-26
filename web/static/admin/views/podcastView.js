import SearchWidget from "components/searchWidget";

export default class PodcastView {
  new() {
    new SearchWidget("person", "podcast", "hosts");
  }

  edit() {
    this.new();
  }
}
