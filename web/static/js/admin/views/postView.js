import SearchWidget from "../components/searchWidget"
import Slugifier from "../components/slugifier"

export default class PostView {
  new() {
    $(".remote.search.dropdown").dropdown({
      fields: {name: "title", value: "id"},
      apiSettings: {
        url: `/admin/search?t=person&q={query}`
      }
    });

    let $slugifier = new Slugifier("#post_title", "#post_slug");
    let $channelWidget = new SearchWidget("channel", "post", "channels");
  }

  edit() {
    this.new()
  }
}
