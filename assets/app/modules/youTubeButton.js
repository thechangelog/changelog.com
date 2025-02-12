import { u } from "umbrellajs";

export default class YouTubeButton {
  constructor(el) {
    this.el = u(el);
    this.videoId = this.el.attr("data-youtube");
    this.origTitle = this.el.attr("title");
    this.origText = this.el.text();
    this.hideText = this.el.attr("data-hide") || "Hide Video";

    if (this.el.attr("data-container")) {
      this.container = u(this.el.attr("data-container"));
      this.beforeMe = this.container.find(".js-video-before-me");
    } else {
      this.container = this.el.closest(".news_item");
      this.beforeMe = this.container.find(".news_item-content");
    }

    el.removeAttribute("data-youtube");

    this.el.handle("click", () => {
      this.toggleShowHide();
    });

    this.load();
  }

  load() {
    let container = document.createElement("div");
    container.className = "news_item-video is-hidden";
    let iframe = document.createElement("iframe");
    iframe.src = `https://www.youtube.com/embed/${this.videoId}?autoplay=1&rel=0&origin=https://changelog.com`;
    iframe.setAttribute("frameborder", "0");
    container.appendChild(iframe);
    this.beforeMe.before(container);
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
    this.container.find(".news_item-video").removeClass("is-hidden");
    this.el
      .addClass("is-active")
      .attr("title", this.hideText)
      .text(this.hideText);
  }

  hide() {
    this.isActive = false;
    this.container.find(".news_item-video").remove();
    this.el
      .removeClass("is-active")
      .attr("title", this.origTitle)
      .text(this.origText);
  }
}
