export default class Log {
  static track(category, action, label) {
    if (typeof ga == "undefined") {
      console.log("[TRACK]", {category: category, action: action, label: label});
    } else {
      ga("send", "event", category, action, label);
      _gs("event", action, {category: category, label: label});
    }
  }
}
