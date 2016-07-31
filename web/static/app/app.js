import { Popper } from "popper.js";

function createClassToggleListener(element, target, toggleClass) {
  element.addEventListener('click', function(e) {
    e.preventDefault();
    target = target || this;
    if (target.classList.contains(toggleClass)) {
        // Since we prevent default, we must manually propagate clicks to the target
        e.target.dispatchEvent(new MouseEvent('click'));
        target.classList.remove(toggleClass);
    } else {
        target.classList.add(toggleClass);
    }
  });
};

// Navigation bar drop downs
var dropdownItems = document.body.querySelectorAll('.navigation-bar-link_dropdown');
Array.from(dropdownItems).forEach(function(node) {
  createClassToggleListener(node.parentElement, null, 'navigation-bar-link--is-open');
});

// Navigation bar tray
var navigationTrayToggleButtons = document.body.querySelectorAll('.navigation-bar_menu-button');
var navigationTray = document.querySelector('.navigation-bar_tray');
Array.from(navigationTrayToggleButtons).forEach(function(node) {
  createClassToggleListener(node, navigationTray, 'navigation-bar_tray--is-open');
});

// Show Summary Widget Toggle
var showSummaryWidgetToggles = document.body.querySelectorAll('.show-summary-widget_toggle');
Array.from(showSummaryWidgetToggles).forEach(function(node) {
  createClassToggleListener(node, node.previousElementSibling, 'show-summary-widget_menu--is-open');
});

function createTogglablePopper(target, popper, options) {
  popper.style.display = 'none';
  options = Object.assign({placement: 'top'}, options);
  target.addEventListener('click', function(e) {
    this.toggled = !this.toggled;
    popper.style.display = this.toggled ? 'block' : 'none';
    this.popper = this.toggled ? new Popper(target, popper, options) : this.popper.destroy();
  });
}

// All podcast menus
var podcastMenuMoreButtons = document.body.querySelectorAll('.podcast-menu_more-button');
var podcastMenuTooltips = document.body.querySelectorAll('.podcast-menu-tooltip');
Array.from(podcastMenuMoreButtons).forEach(function(node, i) {
  createTogglablePopper(node, podcastMenuTooltips[i], {placement: 'right'});
});

// Podcast player
var sharePodcastButtons = document.body.querySelectorAll('.share-podcast_btn');
var sharePodcastToolTips = document.body.querySelectorAll('.share-podcast-tooltip');
Array.from(sharePodcastButtons).forEach(function(node, i) {
  createTogglablePopper(node, sharePodcastToolTips[i]);
})
