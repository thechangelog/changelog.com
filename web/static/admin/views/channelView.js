import Slugifier from "components/slugifier";

export default class ChannelView {
  new() {
    let $slugifier = new Slugifier("#channel_name", "#channel_slug");
  }

  edit() {
    this.new()
  }
}
