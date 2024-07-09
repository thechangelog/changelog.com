import Log from "modules/log";

export default class News {
  constructor() {
    this.iframe = document.getElementById("newsletter_iframe");
    this.container = document.getElementById("newsletter_iframe-container");
    this.testimonialsPlayed = 0;

    document.querySelectorAll(".js-play-pause").forEach((el) => {
      el.addEventListener("click", this.togglePlayPause.bind(this));
    });

    window.onload = () => {
      if (location.href.includes("#reasons")) {
        this.toggleReasons();
      }

      this.goToTestimonial(Math.floor(Math.random() * 4));
    };

    if (this.iframe) {
      this.iframe.onload = () => {
        this.resizeFrameToFit();
        this.makeFrameLinksOpenInNewTab();
      };
    }

    window.onresize = () => {
      this.resizeFrameToFit();
    };

    setInterval(() => {
      this.nextTestimonial();
    }, 7500);
  }

  resizeFrameToFit() {
    const scrollHeight = this.iframe.contentWindow.document.body.scrollHeight;

    this.iframe.style.height = `${scrollHeight}px`;
    this.container.style.flex = `1 0 ${scrollHeight}px`;
  }

  makeFrameLinksOpenInNewTab() {
    const links = this.iframe.contentDocument.getElementsByTagName("a");

    for (var i = 0; i < links.length; i++) {
      links[i].target = "_blank";
    }
  }

  nextTestimonial() {
    // Make sure we aren't hovering over the parent
    if (document.querySelector(".testimonials").matches(":hover")) return;

    this.testimonialsPlayed++;

    const testimonials = document.querySelectorAll(".testimonials-item");
    const activeTestimonial = document.querySelector(
      ".testimonials-item.is-active"
    );

    if (this.testimonialsPlayed == testimonials.length) {
      return;
    }

    let nextIndex = Array.from(testimonials).indexOf(activeTestimonial) + 1;

    if (nextIndex == testimonials.length) {
      nextIndex = 0;
    }

    this.goToTestimonial(nextIndex);
  }

  goToTestimonial(index) {
    // Get all slides and pagination buttons
    const testimonials = document.querySelectorAll(".testimonials-item");
    const paginationButtons = document.querySelectorAll(
      ".testimonials-pagination li button"
    );

    // Hide all slides and remove "is-active" class from pagination buttons
    testimonials.forEach(function (slide) {
      slide.classList.remove("is-active");
    });
    paginationButtons.forEach(function (button) {
      button.parentNode.classList.remove("is-active");
    });

    // Show the selected slide and add "is-active" class to its corresponding pagination button
    testimonials[index].classList.add("is-active");
    paginationButtons[index].parentNode.classList.add("is-active");
  }

  togglePlayPause(event) {
    event.preventDefault();

    const issue = event.target.parentNode;

    if (!issue.audio) {
      issue.button = event.target;
      issue.audio = new Audio();
      issue.audio.src = event.target.href;
      issue.audio.type = "audio/mpeg";
      issue.title = event.target.getAttribute("data-title");
      issue.progress = 0;
      issue.audio.addEventListener("canplaythrough", function () {
        issue.audio.play();
        Log.track("News Player", { action: "Play", audio: issue.title });
      });

      issue.audio.addEventListener("timeupdate", function () {
        if (isFinite(issue.audio.duration)) {
          const progress =
            (issue.audio.currentTime / issue.audio.duration) * 100;
          const rounded = Math.round(progress * 10) / 10;

          if (issue.progress < rounded) {
            issue.progress = rounded;
            issue.querySelector(".progress_bar").style =
              `--progress: ${rounded}%`;
          }
        }
      });
    }

    if (issue.classList.contains("is-playing")) {
      this.pauseIssue(issue);
    } else {
      this.playIssue(issue);
    }
  }

  pauseIssue(issue) {
    if (issue.audio) {
      issue.audio.pause();
      issue.classList.add("is-paused");
      issue.classList.remove("is-playing");
      issue.button.children[0].innerText = "PLAY";
    }
  }

  playIssue(issue) {
    // pause all other issues that might be playing
    document.querySelectorAll(".js-issue").forEach((el) => {
      if (el !== issue) {
        this.pauseIssue(el);
      }
    });

    issue.audio.play();
    issue.classList.remove("is-paused");
    issue.classList.add("is-playing");
    issue.button.children[0].innerText = "PAUSE";
  }

  toggleReasons() {
    const reasons = document.querySelector(".reasons");
    reasons.classList.toggle("is-visible");

    const isVisible = reasons.classList.contains("is-visible");

    // Ensure we are scrolled to the top
    if (isVisible) {
      reasons.scrollTo({
        top: reasons.offsetTop
      });
    }

    // Don"t allow the body to scroll when modal is open
    document.body.classList.toggle("no-scroll", isVisible);
  }
}

window.news = new News();
