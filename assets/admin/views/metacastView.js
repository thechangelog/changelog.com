import SearchWidget from "components/searchWidget";

export default class MetacastView {
  new() {
    new SearchWidget("podcast", "metacast", "included_podcasts");
    new SearchWidget("topic", "metacast", "included_topics");

    new SearchWidget("podcast", "metacast", "excluded_podcasts");
    new SearchWidget("topic", "metacast", "excluded_topics");
  }

  edit() {
    this.new();
  }
}