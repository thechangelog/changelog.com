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
    let minutes = Math.ceil(Math.abs(new Date() - this.date) / 1000 / 60);

    if (minutes < 60) {
      return `${this._pluralize(minutes, "minute")} ago`;
    }

    let hours = Math.round(minutes / 60);

    if (hours < 24) {
      return `${this._pluralize(hours, "hour")} ago`;
    }

    let days = Math.round(hours / 24);

    if (days < 7) {
      return `${this._pluralize(days, "day")} ago`;
    }

    let weeks = Math.round(days / 7);

    if (weeks < 4) {
      return `${this._pluralize(weeks, "week")} ago`;
    }

    let months = Math.round(weeks / 4);

    if (months < 12) {
      return `${this._pluralize(months, "month")} ago`;
    }

    let years = Math.round(months / 12);

    return `${this._pluralize(years, "year")} ago`;
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
