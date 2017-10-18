import Slugifier from "components/slugifier";

export default class TopicView {
  new() {
    new Slugifier("#topic_name", "#topic_slug");
  }

  edit() {
    this.new()
  }
}
