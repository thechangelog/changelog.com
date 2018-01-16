const days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
const months = ["January", "February", "March", "April", "May", "June", "July", "August","September","October","November","December"];

class Time {
  constructor(date) {
    this.date = date;
    this.hours = date.getHours();
  }

  year() {
    return this.fullYear().substr(2, 2);
  }

  fullYear() {
   return this.date.getFullYear().toString();
  }

  month() {
    return this.date.getMonth() + 1;
  }

  day() {
    return this.date.getDate();
  }

  hours12() {
   if (this.hours > 12) {
    return this.hours - 12;
   } else {
    return this.hours;
   }
  }

  hours24() {
    return this.hours;
  }

  minutes(fallback) {
    let m = this.date.getMinutes();

    if (m == 0) {
      m = fallback;
    } else if (m < 10) {
      m = `:0${m}`;
    } else {
      m = `:${m}`;
    }

    return m;
  }

  amPm() {
    if (this.hours > 12) {
      return "PM";
    } else {
      return "AM";
    }
  }

  tz() {
    return this.date.toString().match(/\(([\w\s]+)\)/)[1];
  }

  weekday() {
    return days[this.date.getDay()];
  }

  month() {
    return this.date.getMonth() + 1;
  }

  monthAbbrev() {
    return this.monthName().substr(0, 3);
  }

  monthName() {
    return months[this.date.getMonth()];
  }

  amPmStyle() {
    return `${this.hours12()}${this.minutes(":00")} ${this.amPm()} ${this.tz()}`;
  }

  adminStyle() {
    return `${this.month()}/${this.day()}/${this.year()} – ${this.hours12()}${this.minutes("")}${this.amPm()} (${this.tz()})`;
  }

  dateStyle() {
    return `${this.monthAbbrev()} ${this.day()}, ${this.fullYear()}`;
  }

  dayAndDateStyle() {
    return `${this.weekday()}, ${this.monthName()} ${this.day()}`;
  }

  liveStyle() {
    return `${this.hours12()}${this.minutes(":00")} ${this.tz()}`;
  }

  timeFirstStyle() {
    return `${this.amPmStyle()} – ${this.dayAndDateStyle()}`;
  }

  relativeStyle() {
    let seconds = Math.abs(new Date() - this.date) / 1000;

    if (seconds < 60*60) {
      return `${this._pluralize(Math.ceil(seconds / 60), "minute")} ago`;
    } else if (seconds < 60*60*24) {
      return `${this._pluralize(Math.round(seconds / 60 / 60), "hour")} ago`;
    } else {
      return `${this._pluralize(Math.round(seconds / 60 / 60 / 24), "day")} ago`;
    }
  }

  _pluralize(number, string) {
    if (number == 1) {
      return `1 ${string}`;
    } else {
      return `${number} ${string}s`;
    }
  }
}

export default function ts(date, style) {
  const t = new Time(date);
  return t[`${style}Style`].call(t);
}
