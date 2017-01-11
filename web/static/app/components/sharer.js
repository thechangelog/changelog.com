import { u, ajax } from "umbrellajs";
import template from "templates/share.hbs";

export default class Sharer {
  constructor(selector) {
    this.attachUI(selector);
    this.attachEvents();
  }

  attachUI(selector) {
    this.container = u(selector);
    this.closeButton = this.container.find(".js-share-close");
    this.content = this.container.find(".js-share-content");
  }

  attachEvents() {
    this.closeButton.handle("click", () => { this.hide(); });
    this.container.on("change", ".js-share-embed-toggle", () => { this.toggleEmbed(); })
  }

  load(detailsUrl) {
    this.resetUI();
    this.show();
    ajax(detailsUrl, {}, (error, data) => {
      this.content.html(template(data));
      this.setEmbed(data.embed);
    });
  }

  setEmbed(text) {
    this.content.find(".js-share-embed").text(text);
  }

  toggleEmbed() {
    const embed = this.content.find(".js-share-embed");
    const text = embed.text().replace(/theme="(\w+)"/, function(match, current) {
      if (current == "night") {
        return "theme=\"day\"";
      } else {
        return "theme=\"night\"";
      }
    });

    embed.text(text);
  }

  resetUI() {
   this.content.html("");
  }

  show() {
    this.container.addClass("is-visible");
  }

  hide() {
    this.container.removeClass("is-visible");
  }
}
