import { u } from 'umbrellajs';
import Siema from 'siema';

export default class slider {
  constructor(selector) {
    // Elements
    this.slider = u(selector);

    // Run
    if (this.slider.length) { this.init(selector); }
  }

  init(selector) {
    // Elements
    const pagination = u('.slider_pagination-item');
    let siemaSlider = false;

    // Variables
    const options = {
      selector,
      duration: 600,
      easing: 'cubic-bezier(0.19, 1, 0.22, 1)',
      perPage: 1,
      draggable: true,
      threshold: 20,
      loop: false,
      onInit: () => {
        // Enable Pagination
        pagination.on('click', function gotoSlide() {
          siemaSlider.goTo(u(this).data('goto'));
        });
      },
      onChange: () => {
        slider.updateActive(siemaSlider.currentSlide);
        slider.resizeSlider(siemaSlider.currentSlide);
      },
    };

    // Init Carousel
    siemaSlider = new Siema(options);
    window.setTimeout(function() {
      slider.updateActive(0);
    }, 1000);

    window.addEventListener("resize", (event) => { slider.resizeSlider(siemaSlider.currentSlide); })
  }

  static updateActive(currentSlide) {
    u('.slider_pagination-item').removeClass('is-active');
    u(`.slider_pagination-item--${currentSlide}`).addClass('is-active');
  }

  static resizeSlider(currentSlide) {
    const height = u('.marketing_slider-item-inner').nodes[currentSlide].offsetHeight;
    u('.js-slider').nodes[0].style.maxHeight = `${height}px`;
  }
}
