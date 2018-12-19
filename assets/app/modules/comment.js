import autosize from "autosize";
import Prism from "prismjs";
import { u, ajax } from "umbrellajs";

export default class Comment {
  constructor(container) {
    this.container = u(container);
    this.id = this.container.data("id");
    this.attachUI();
    this.attachEvents();
    this.attachKeyboardShortcuts();
    container.comment = this;
  }

  attachUI() {
    this.replyForm = this.container.children("form");
    this.replyTextArea = this.replyForm.find("textarea").first();
    this.previewArea = this.replyForm.find(".js-comment-preview-area");
    this.csrf = this.replyForm.find("input[name=_csrf_token]").attr("value");
    this.collapseButton = this.container.children(".js-comment-collapse");
    this.replyButton = this.container.children("footer").find(".js-comment-reply");
    this.previewButton = this.replyForm.find(".js-comment-preview");
    this.writeButton = this.replyForm.find(".js-comment-write");
    this.replies = this.container.children(".comment-replies");
  }

  attachEvents() {
    this.collapseButton.handle("click", _ => { this.container.toggleClass("is-collapsed") });
    this.replyButton.handle("click", _ => { this.toggleReplyForm() });
    this.previewButton.handle("click", _ => { this.showPreview() });
    this.writeButton.handle("click", _ => { this.showWrite() });
  }

  attachKeyboardShortcuts() {
    this.replyForm.on("keydown", event => {
      // ctrl+enter or cmd+enter submits form
      if ((event.metaKey || event.ctrlKey) && event.key == "Enter") {
        event.preventDefault();
        this.replyForm.trigger("submit");
      }
    });
  }

  detectPermalink() {
    if (location.hash.match(this.id)) {
      this.container.addClass("is-permalink");
    } else {
      this.container.removeClass("is-permalink");
    }
  }

  showPreview() {
    let options = {
      method: "POST",
      headers: {"x-csrf-token": this.csrf},
      body: {"md": this.replyTextArea.value}
    }

    ajax("/news/comments/preview", options, (_err, resp) => {
      this.previewArea.html(resp);
      Prism.highlightAllUnder(this.previewArea.first());
      this.replyForm.addClass("comment_form--preview");
    });
  }

  showWrite() {
    this.previewArea.html("");
    this.replyForm.removeClass("comment_form--preview");
  }

  toggleReplyForm() {
    if (!this.replyForm.length) {
      Turbolinks.visit("/in");
    } else if (this.replyForm.hasClass("is-hidden")) {
      this.openReplyForm();
    } else {
      this.closeReplyForm();
    }
  }

  openReplyForm() {
    this.replyForm.removeClass("is-hidden");
    this.replyTextArea.focus();
    this.replyButton.text("cancel");
  }

  closeReplyForm() {
    this.replyForm.addClass("is-hidden");
    this.replyButton.text("reply");
  }

  clearReplyForm() {
    this.showWrite();
    this.replyForm.first().reset();
    autosize.update(this.replyTextArea);
  }

  // this is only called on the very first comment form, not replies
  addComment(content) {
    this.clearReplyForm();
    this.container.after(content);
  }

  addReply(comment) {
    this.replies.prepend(comment);
    this.container.addClass("comment--has_replies");
    this.clearReplyForm();
    this.closeReplyForm();
  }
}
