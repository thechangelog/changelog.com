import { u } from "umbrellajs";

export default class YouTubeButton {
  constructor(el) {
    this.el = u(el);
    this.videoId = this.el.attr("data-youtube");
    el.removeAttribute("data-youtube");
    this.item = this.el.closest(".news_item");
    this.load();
    this.el.handle("click", () => { this.toggleShowHide(); })
  }

  load() {
    let container =  document.createElement("div");
    container.className = "news_item-video is-hidden";
    let iframe = document.createElement("iframe");
    iframe.src = `https://www.youtube.com/embed/${this.videoId}?autoplay=1&rel=0&origin=https://changelog.com`;
    iframe.setAttribute("frameborder", "0");
    container.appendChild(iframe);
    this.item.append(container);
    this.show();
  }

  toggleShowHide() {
    if (this.isActive) {
      this.hide();
    } else {
      this.load();
    }
  }

  show() {
    this.isActive = true;
    this.item.find(".news_item-video").removeClass("is-hidden");
    this.el.addClass("is-active").attr("title", "Hide Video").text("Hide Video");
  }

  hide() {
    this.isActive = false;
    this.item.find(".news_item-video").remove();
    this.el.removeClass("is-active").attr("title", "Hide Video").text("Play Video");
  }
}
