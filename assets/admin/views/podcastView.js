import SearchWidget from "components/searchWidget";

export default class PodcastView {
  new() {
    new SearchWidget("person", "podcast", "hosts");
    new SearchWidget("topic", "podcast", "topics");
  }

  edit() {
    this.new();
  }
}
