import { u, ajax } from "umbrellajs";

export default class Comment {
  constructor(container) {
    this.container = u(container);
    this.attachUI();
    this.attachEvents();
  }

  attachUI() {
    this.replyForm = this.container.children("form");
    this.replyTextArea = this.replyForm.find("textarea").first();
    this.previewArea = this.replyForm.find(".js-comment-preview-area");
    this.csrf = this.replyForm.find("input[name=_csrf_token").attr("value");
    this.collapseButton = this.container.children(".js-comment-collapse");
    this.replyButton = this.container.children("header").find(".js-comment-reply");
    this.previewButton = this.replyForm.find(".js-comment-preview");
    this.writeButton = this.replyForm.find(".js-comment-write");
  }

  attachEvents() {
    this.collapseButton.handle("click", _ => { this.container.toggleClass("is-collapsed") });
    this.replyButton.handle("click", _ => { this.toggleReplyForm() });
    this.previewButton.handle("click", _ => { this.showPreview() });
    this.writeButton.handle("click", _ => { this.showWrite() });
  }

  showPreview() {
    let options = {
      method: "POST",
      headers: {"x-csrf-token": this.csrf},
      body: {"md": this.replyTextArea.value}
    }

    ajax("/news/comments/preview", options, (_err, resp) => {
      this.previewArea.html(resp);
      this.replyForm.addClass("comment_form--preview");
    });
  }

  showWrite() {
    this.replyForm.removeClass("comment_form--preview");
  }

  toggleReplyForm() {
    if (!this.replyForm.length) {
      Turbolinks.visit("/in");
    } else if (this.replyForm.hasClass("is-hidden")) {
      this.replyForm.removeClass("is-hidden");
      this.replyButton.text("cancel");
    } else {
      this.replyForm.addClass("is-hidden");
      this.replyButton.text("reply");
    }
  }
}
