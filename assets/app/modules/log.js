export default class Log {
  static track(event, props) {
    if (typeof plausible !== "undefined") {
      // ga("send", "event", event, props.action, props.label);
      plausible(category, {props: props});
    } else {
      console.log("[TRACK]", event, props);
    }
  }
}
