import { u } from "umbrellajs";
import template from "templates/itemImage.hbs";

export default class ImageButton {
  constructor(el) {
    this.el = u(el);
    this.imageUrl = this.el.attr("data-image");
    this.imageWidth = this.el.attr("data-width");
    el.removeAttribute("data-image");
    this.item = this.el.closest(".news_item");
    this.load();
    this.el.handle("click", () => { this.toggleShowHide(); })
  }

  load() {
    this.item.append(template({src: this.imageUrl, width: this.imageWidth}));
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
