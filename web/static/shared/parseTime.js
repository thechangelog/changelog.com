// courtesy https://github.com/davatron5000/TimeJump
export default function parseTime(string) {
  if (!string) return null;

  let seconds = /^\d+(\.\d+)?$/g;
  let colons  = /^(?:colons:)?(?:(?:(\d+):)?(\d\d?):)?(\d\d?)(\.\d+)?$/;
  let youtube = /^(?:(\d\d?)[hH])?(?:(\d\d?)[mM])?(\d\d?)[sS]$/;

  if (seconds.test(string)) {
    return parseFloat(string);
  }

  let match = colons.exec(string) || youtube.exec(string);

  if (match) {
    return (3600 * (parseInt(match[1], 10) || 0) + 60 * (parseInt(match[2], 10) || 0) + parseInt(match[3], 10) + (parseFloat(match[4]) || 0));
  }

  return 0;
}
