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
dropdownItems.forEach(function(node) {
    createClassToggleListener(node.parentElement, null, 'navigation-bar-link--is-open');
});

// Navigation bar tray
var navigationTrayToggleButtons = document.body.querySelectorAll('.navigation-bar_menu-button');
var navigationTray = document.querySelector('.navigation-bar_tray');
navigationTrayToggleButtons.forEach(function(node) {
    createClassToggleListener(node, navigationTray, 'navigation-bar_tray--is-open');
});

// Show Summary Widget Toggle
var showSummaryWidgetToggles = document.body.querySelectorAll('.show-summary-widget_toggle');
showSummaryWidgetToggles.forEach(function(node) {
    createClassToggleListener(node, node.previousElementSibling, 'show-summary-widget_menu--is-open');
});
