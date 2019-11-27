import Clipboard from "clipboard";

export default class SponsorView {
  show() {
    let clipboard = new Clipboard(".clipboard.button");

    clipboard.on("success", function(e) {

      $(e.trigger).popup({variation: "inverted", content: "Copied!"}).popup("show");
    });

    clipboard.on("error", function(e) { console.log(e); });
  }
}
