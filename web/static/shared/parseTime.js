// original ~> https://github.com/davatron5000/TimeJump
export default function parseTime(string) {
  if (!string) return null;

  let seconds = 0;
  let colons  = /^(?:colons:)?(?:(?:(\d+):)?(\d\d?):)?(\d\d?)(\.\d+)?$/;
  let youtube = /^(?:(\d\d?)[hH])?(?:(\d\d?)[mM])?(?:(\d\d?)[sS])?$/;
  let decimal = /^\d+(\.\d+)?$/g;

  let match = colons.exec(string) || youtube.exec(string);

  if (match) {
    seconds = calculateSeconds(match);
  } else if (decimal.test(string)) {
    seconds = parseFloat(string);
  } else {
    // no-op
  }

  return seconds;
}

function calculateSeconds(match) {
  return 60 * 60 * (parseInt(match[1], 10) || 0) + // hours
         60 * (parseInt(match[2], 10) || 0) + // minutes
         (parseInt(match[3], 10) || 0) + // seconds
         (parseFloat(match[4]) || 0); // sub-second
}
