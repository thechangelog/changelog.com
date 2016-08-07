export function createClassToggleListener(element, target, toggleClass) {
    element.addEventListener('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        target = target || this;
        if (target.classList.contains(toggleClass)) {
            if (e.target !== this) {
                // Since we prevent default, we must manually propagate clicks to the target
                e.target.dispatchEvent(new MouseEvent('click'));
            }
            target.classList.remove(toggleClass);
        } else {
            target.classList.add(toggleClass);
        }
    });
};

export function makeToggles(elementClass, targetClass, toggleClass) {
    const toggleElements = document.body.querySelectorAll(elementClass);
    const targetElement = targetClass ? document.querySelector(targetClass) : null;
    toggleElements.forEach(function(node) {
        createClassToggleListener(targetElement ? node : node.parentElement, targetElement, toggleClass);
    });
}
