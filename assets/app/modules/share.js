import { u, ajax } from "umbrellajs";
import template from "templates/share.hbs";
import Clipboard from "clipboard";

export default class Share {
  constructor(overlay) {
    this.overlay = overlay;
    this.isAttached = false;
  }

  attach() {
    // ui
    this.embed = this.overlay.find(".js-share-embed");
    this.toggleEmbedButton = this.overlay.find(".js-share-embed-toggle");
    this.copyUrlButton = this.clipboardFor(".js-share-copy-url");
    this.copyEmbedButton = this.clipboardFor(".js-share-copy-embed");
    // events
    this.toggleEmbedButton.on("change", () => { this.toggleEmbed(); });
    this.attachKeyboardShortcuts();
    // yup
    this.isAttached = true;
  }

  attachKeyboardShortcuts() {
    u(document).on("keydown", event => {
      if (!this.isAttached) return;

      switch (event.keyCode) {
        case 27: // escape
          this.detach();
          break;
        default:
      }
    });
  }

  detach() {
    if (!this.isAttached) return false;

    // events
    this.toggleEmbedButton.off("change");
    this.copyUrlButton.destroy();
    this.copyEmbedButton.destroy();
    // ui
    this.overlay.hide("");
  }

  load(detailsUrl) {
    this.detach();
    this.overlay.show();

    ajax(detailsUrl, {}, (error, data) => {
      this.overlay.html(template(data));
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

  clipboardFor(selector) {
    return new Clipboard(selector, {
      target: function(trigger) { return trigger.previousElementSibling; }
    }).on("success", function(e) {
      u(e.trigger).text("Copied!");
      window.setTimeout(function() {
        u(e.trigger).text("Copy");
      }, 3000);
      e.clearSelection();
    });
  }
}
