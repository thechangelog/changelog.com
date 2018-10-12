import { u, ajax } from "umbrellajs";

export default class Commment {
  constructor() {
    // ui
    this.commentForms = u(".js-comment_form");
    this.toggleButton = u(".js-toggle_comment");
    this.toggleReply = u(".js-toggle-reply");
    this.toggleWrite = u(".js-toggle_write");
    this.togglePreview = u(".js-toggle_preview");
    this.permalink = u(".js-permalink");
    // events
    this.toggleButton.on("click", (event) => {
      u(event.currentTarget).closest(".comment").toggleClass("is-collapsed");
    });
    this.togglePreview.on("click", (event) => {
      event.preventDefault();
      this.showPreview(event.currentTarget);
    });
    this.toggleWrite.on("click", (event) => {
      event.preventDefault();
      this.showWrite(event.currentTarget);
    });

    this.toggleReply.handle("click", (event) => {
      u(event.target)
      .closest(".comment")
      .children("form")
      .toggleClass("is-hidden");
    })

    this.permalink.on("click", (event) => {
      event.preventDefault();
      const target = u(event.target);
      const comment = target.closest(".comment");
      const href = target.attr("href");
      location.hash = href;
      this.togglePermalink(comment);
    });
  }

  showPreview(button) {
    const commentForm = u(button).closest(".comment_form");
    commentForm.addClass('comment_form--preview');
  }

  showWrite(button) {
    const commentForm = u(button).closest(".comment_form");
    commentForm.removeClass('comment_form--preview');
  }

  togglePermalink(comment) {
    u(".comment").removeClass("is-permalink");
    comment.toggleClass("is-permalink").removeClass("is-collapsed");
  }
}
