import { u } from "umbrellajs";

export default class ImageButton {
  constructor(el) {
    this.el = u(el);
    this.imageUrl = this.el.attr("data-image");
    el.removeAttribute("data-image");
    this.item = this.el.closest(".news_item");
    this.load();
    this.el.handle("click", () => { this.toggleShowHide(); })
  }

  load() {
    let container =  document.createElement("div");
    container.className = "news_item-image is-hidden";
    let image = new Image();

    let item = this.item.first();
    image.src = this.imageUrl;
    image.onload = function() {
      if (this.naturalWidth < item.clientWidth) {
        image.width = this.naturalWidth;
      }

      container.appendChild(image);
    }

    this.item.append(container);
    this.show();
  }

  toggleShowHide() {
    if (this.isActive) {
      this.hide();
    } else {
      this.show();
    }
  }

  show() {
    this.isActive = true;
    this.item.find(".news_item-image").removeClass("is-hidden");
    this.el.addClass("is-active").text("Hide Image");
  }

  hide() {
    this.isActive = false;
    this.item.find(".news_item-image").addClass("is-hidden");
    this.el.removeClass("is-active").text("View Image");
  }
}
