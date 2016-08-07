import { makePoppers } from "./poppers.js";
import { makeToggles } from "./toggles.js";

(function(makePoppers, makeToggles){
  // Toggles
  makeToggles('.navigation-bar-link_dropdown', undefined, 'navigation-bar-link--is-open');
  makeToggles('.navigation-bar_menu-button', '.navigation-bar_tray', 'navigation-bar_tray--is-open');
  makeToggles('.show-summary-widget_toggle', '.show-summary-widget_menu', 'show-summary-widget_menu--is-open');

  // Poppers
  makePoppers('.podcast-menu_more-button', '.podcast-menu-tooltip');
  makePoppers('.share-podcast_btn', '.share-podcast-tooltip');
}(makePoppers, makeToggles));