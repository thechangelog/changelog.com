// yoinked from http://www.netlobo.com/url_query_string_javascript.html
// then modified to accept optional delimiter (for fragments)
export default function gup(name, url, delimiter) {
    if (!url) url = location.href;
    if (!delimiter) delimiter = "?";
    name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
    var regexS = `[\\${delimiter}&]${name}=([^&#]*)`;
    var regex = new RegExp(regexS);
    var results = regex.exec(url);
    return results == null ? null : results[1];
}
