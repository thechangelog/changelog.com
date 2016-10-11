export default class Log {
  static track(eventName, eventData) {
    if (typeof _gs == "undefined") {
      console.log("[TRACK]", eventName, eventData);
    } else {
      if (eventData) {
        _gs("event", eventName, eventData);
      } else {
        _gs("event", eventName);
      }
    }
  }
}
