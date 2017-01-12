import { u, ajax } from "umbrellajs";
import template from "templates/share.hbs";
import Clipboard from "clipboard";

export default class Sharer {
  constructor(selector) {
    this.container = u(selector);
    this.closeButton = this.container.find(".js-share-close");
    this.content = this.container.find(".js-share-content");
    this.isAttached = false;
  }

  attach() {
    // ui
    this.embed = this.content.find(".js-share-embed");
    this.toggleEmbedButton = this.content.find(".js-share-embed-toggle");

    this.copyUrlButton = new Clipboard(".js-share-copy-url", {
      target: function(trigger) { return trigger.previousElementSibling; }
    });

    this.copyEmbedButton = new Clipboard(".js-share-copy-embed", {
      target: function(trigger) { return trigger.previousElementSibling; }
    });

    // events
    this.closeButton.handle("click", () => { this.hide(); });
    this.toggleEmbedButton.on("change", () => { this.toggleEmbed(); });

    this.isAttached = true;
  }

  detach() {
    if (!this.isAttached) {
      return false;
    }

    // events
    this.closeButton.off("click");
    this.toggleEmbedButton.off("change");
    this.copyUrlButton.destroy();
    this.copyEmbedButton.destroy();
    // ui
    this.content.html("");
  }

  load(detailsUrl) {
    this.detach();
    this.show();

    ajax(detailsUrl, {}, (error, data) => {
      this.content.html(template(data));
      this.attach();
      this.embed.text(data.embed);
    });
  }

  toggleEmbed() {
    const before = this.embed.text();
    const after = before.replace(/theme="(\w+)"/, function(match, current) {
      if (current == "night") {
        return "theme=\"day\"";
      } else {
        return "theme=\"night\"";
      }
    });

    this.embed.text(after);
  }

  show() {
    this.container.addClass("is-visible");
  }

  hide() {
    this.container.removeClass("is-visible");
  }
}
