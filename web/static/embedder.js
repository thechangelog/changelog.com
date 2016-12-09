// this script gets uploaded directly to Fastly for serving.
(function(d) {
  var origin = "https://changelog.com";
  var embeds = d.getElementsByClassName("changelog-episode");
  var players = [];

  function Player(element) {
    var src = element.getAttribute("data-src");
    var theme = element.getAttribute("data-theme") || "night";
    var iframe = d.createElement("iframe");
    iframe.setAttribute("src", src + "?theme=" + theme + "&referrer=" + d.location.href);
    iframe.setAttribute("width", "100%");
    iframe.setAttribute("height", "220");
    iframe.setAttribute("srcolling", "no");
    iframe.setAttribute("frameborder", "no");
    element.parentNode.replaceChild(iframe, element);

    this.id = +new Date;
    this.src = iframe.src;
    this.iframe = iframe;
  }

  var send = function(player, data) {
    data.context = "player.js";
    data.version = "0.0.11";
    data.listener = player.id;
    player.iframe.contentWindow.postMessage(JSON.stringify(data), origin);
  }

  var receive = function(event) {
    if (event.origin !== origin) return false;
    var message = JSON.parse(event.data);
    if (message.context !== "player.js") return false;

    if (message.event === "ready") {
      for (var i = players.length - 1; i >= 0; i--) {
        if (players[i].src === message.value.src) {
          send(players[i], {method: "addEventListener", value: "play"});
        }
      }
    }

    if (message.event === "play") {
      for (var i = players.length - 1; i >= 0; i--) {
        if (players[i].id !== message.listener) {
          send(players[i], {method: "pause"});
        }
      }
    }
  }

  window.addEventListener("message", receive);

  for (var i = embeds.length - 1; i > -1; i--) {
    players.push(new Player(embeds[i]));
  }
})(document);
