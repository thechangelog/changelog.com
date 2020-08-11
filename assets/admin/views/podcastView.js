import SearchWidget from "components/searchWidget";

export default class PodcastView {
  new() {
    new SearchWidget("person", "podcast", "podcast_hosts");
    new SearchWidget("topic", "podcast", "podcast_topics");
  }

  edit() {
    this.new();
  }
}
