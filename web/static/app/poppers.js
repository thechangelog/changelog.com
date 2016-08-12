import Popper from "popper.js";

export function createTogglablePopper(target, popper, optionOverrides) {
  popper.style.display = 'none';
  const options = Object.assign({
    placement: 'bottom',
  }, optionOverrides);
  target.addEventListener('click', function(e) {
    this.toggled = !this.toggled;
    popper.style.display = this.toggled ? 'block' : 'none';
    this.popper = this.toggled ? new Popper(target, popper, options) : this.popper.destroy();
    console.log(this.popper);
  });
}

export function makePoppers(buttonClass, popperClass, options) {
    const buttons = document.body.querySelectorAll(buttonClass);
    const poppers = document.body.querySelectorAll(popperClass);
    if (buttons.length && poppers.length) {
      buttons.forEach(function(node, i) {
        createTogglablePopper(node, poppers[i], options);
      });
    }
}