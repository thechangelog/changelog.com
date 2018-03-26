const days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
const months = ["January", "February", "March", "April", "May", "June", "July", "August","September","October","November","December"];

export default class Time {
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

  monthAbbrev() {
    return this.monthName().substr(0, 3);
  }

  monthName() {
    return months[this.date.getMonth()];
  }

  monthString() {
    return this.month() < 10 ? `0${this.month()}` : this.month();
  }

  day() {
    return this.date.getDate();
  }

  dayString() {
    return this.day() < 10 ? `0${this.day()}` : this.day();
  }

  weekday() {
    return days[this.date.getDay()];
  }

  hours12() {
    if (this.hours == 0) {
      return 12;
    } else if (this.hours > 12) {
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
    if (this.hours >= 12) {
      return "PM";
    } else {
      return "AM";
    }
  }

  tz() {
    return this.date.toString().match(/\(([\w\s]+)\)/)[1];
  }

  amPmStyle() {
    return `${this.hours12()}${this.minutes(":00")} ${this.amPm()} ${this.tz()}`;
  }

  adminStyle() {
    return `${this.month()}/${this.day()}/${this.year()} – ${this.hours12()}${this.minutes("")}${this.amPm()}`;
  }

  dateStyle() {
    return `${this.fullYear()}-${this.monthString()}-${this.dayString()}`;
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

  relativeLongStyle() {
    return this._relativeStyle(true);
  }

  relativeShortStyle() {
    return this._relativeStyle(false);
  }

  _relativeStyle(long) {
    let minutes = Math.ceil(Math.abs(new Date() - this.date) / 1000 / 60);

    if (minutes < 60) {
      return long ? `${this._pluralize(minutes, "minute")} ago` : `${minutes}m`;
    }

    let hours = Math.round(minutes / 60);

    if (hours < 24) {
      return long ? `${this._pluralize(hours, "hour")} ago` : `${hours}h`;
    }

    let days = Math.round(hours / 24);

    if (days < 7) {
      return long ? `${this._pluralize(days, "day")} ago` : `${days}d`;
    }

    let weeks = Math.round(days / 7);

    if (weeks < 4) {
      return long ? `${this._pluralize(weeks, "week")} ago` : `${weeks}w`;
    }

    let months = Math.round(weeks / 4);

    if (months < 12) {
      return long ? `${this._pluralize(months, "month")} ago` : `${months}m`;
    }

    let years = Math.round(months / 12);

    return long ? `${this._pluralize(years, "year")} ago` : `${years}y`;
  }

  _pluralize(number, string) {
    if (number == 1) {
      return `1 ${string}`;
    } else {
      return `${number} ${string}s`;
    }
  }
}
