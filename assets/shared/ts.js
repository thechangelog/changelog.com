import Time from "./time";

export default function ts(date, style) {
  const t = new Time(date);
  return t[`${style}Style`].call(t);
}
