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
    // Reply textbox and new text box actions
    this.replyForm = this.container.children(
      'form[data-context="reply"], form[data-context="new"]'
    );
    this.replyTextArea = this.replyForm.find("textarea").first();
    this.previewArea = this.replyForm.find(".js-comment-preview-area");
    this.collapseButton = this.container.children(".js-comment-collapse");
    this.replyButton = this.container
      .children("footer")
      .find(".js-comment-reply");
    this.previewButton = this.replyForm.find(".js-comment-preview");
    this.writeButton = this.replyForm.find(".js-comment-write");
    this.replies = this.container.children(".comment-replies");

    // Edit textbox actions
    this.editForm = this.container.children('form[data-context="edit"]');
    this.editButton = this.container
      .children("footer")
      .find(".js-comment-edit");
    this.editTextArea = this.editForm.find("textarea").first();
    this.editPreviewArea = this.editForm.find(".js-comment-preview-area");
    this.editPreviewButton = this.editForm.find(".js-comment-preview");
    this.editWriteButton = this.editForm.find(".js-comment-write");
  }

  attachEvents() {
    this.collapseButton.handle("click", (_) => {
      this.container.toggleClass("is-collapsed");
    });
    this.replyButton.handle("click", (_) => {
      this.toggleReplyForm();
    });
    this.editButton.handle("click", (_) => {
      this.toggleEditForm();
    });
    this.previewButton.handle("click", (_) => {
      this.showPreview();
    });
    this.editPreviewButton.handle("click", (_) => {
      this.showEditPreview();
    });
    this.previewArea.handle("click", (_) => {
      this.showWrite();
    });
    this.writeButton.handle("click", (_) => {
      this.showWrite();
    });
    this.editPreviewArea.handle("click", (_) => {
      this.showEditWrite();
    });
    this.editWriteButton.handle("click", (_) => {
      this.showEditWrite();
    });
  }

  attachKeyboardShortcuts() {
    this.replyForm.on("keydown", (event) => {
      // ctrl+enter or cmd+enter submits form
      if ((event.metaKey || event.ctrlKey) && event.key == "Enter") {
        event.preventDefault();
        this.replyForm.first().submit();
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
      body: { md: this.replyTextArea.value }
    };

    ajax("/news/comments/preview", options, (_err, resp) => {
      this.previewArea.html(resp);
      Prism.highlightAllUnder(this.previewArea.first());
      this.replyForm.addClass("comment_form--preview");
    });
  }

  showEditPreview() {
    let options = {
      method: "POST",
      body: { md: this.editTextArea.value }
    };

    ajax("/news/comments/preview", options, (_err, resp) => {
      this.editPreviewArea.html(resp);
      Prism.highlightAllUnder(this.editPreviewArea.first());
      this.editForm.addClass("comment_form--preview");
    });
  }

  showWrite() {
    let endPosition = this.replyTextArea.value.length;
    this.previewArea.html("");
    this.replyForm.removeClass("comment_form--preview");
    this.replyTextArea.focus();
    this.replyTextArea.setSelectionRange(endPosition, endPosition);
  }

  showEditWrite() {
    let endPosition = this.editTextArea.value.length;
    this.editPreviewArea.html("");
    this.editForm.removeClass("comment_form--preview");
    this.editTextArea.focus();
    this.editTextArea.setSelectionRange(endPosition, endPosition);
  }

  // Reply form related functions
  toggleReplyForm() {
    if (!this.replyForm.length) {
      window.location.href = "/in";
    } else if (this.replyForm.hasClass("is-hidden")) {
      this.openReplyForm();
    } else {
      this.closeReplyForm();
    }
  }

  openReplyForm() {
    this.replyForm.removeClass("is-hidden");
    this.replyTextArea.focus();
    this.editButton.addClass("is-hidden");
    this.replyButton.text("cancel");
  }

  closeReplyForm() {
    this.replyForm.addClass("is-hidden");
    this.editButton.removeClass("is-hidden");
    this.replyButton.text("reply");
  }

  clearReplyForm() {
    this.showWrite();
    this.replyForm.first().reset();
    autosize.update(this.replyTextArea);
  }

  // Edit form related functions
  toggleEditForm() {
    if (!this.editForm.length) {
      window.location.href = "/in";
    } else if (this.editForm.hasClass("is-hidden")) {
      this.openEditForm();
    } else {
      this.closeEditForm();
    }
  }

  openEditForm() {
    this.editForm.removeClass("is-hidden");
    this.editTextArea.focus();
    this.replyButton.addClass("is-hidden");
    this.editButton.text("cancel");
  }

  closeEditForm() {
    this.editForm.addClass("is-hidden");
    this.replyButton.removeClass("is-hidden");
    this.editButton.text("edit");
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
