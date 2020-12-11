export default class Log {
  static track(event, props) {
    if (typeof plausible !== "undefined") {
      // ga("send", "event", event, props.action, props.label);
      plausible(event, {props: props});
    } else {
      console.log("[TRACK]", event, props);
    }
  }
}
