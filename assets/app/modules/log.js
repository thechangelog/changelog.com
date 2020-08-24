export default class Log {
  static track(category, action, label) {
    if (typeof plausible !== "undefined") {
      // plausible does not yet support extra event data like ga did
      // ga("send", "event", category, action, label);
      plausible(category);
    } else {
      console.log("[TRACK]", {category: category, action: action, label: label});
    }
  }
}
