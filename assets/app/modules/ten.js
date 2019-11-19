import { u } from 'umbrellajs';
import { CountUp } from 'countup.js';
import GLightbox from 'glightbox'

export default class Ten {
  constructor() {
    // Elements
    this.numbers = u('.js-increment');
    this.lightboxItems = u('.js-lightbox');

    const lightbox = GLightbox();

    // Add observer for number count up
    const observer = new IntersectionObserver(function(entries) {
      entries.forEach(entry => {
        let numberEl = u(entry.target);
        Ten.incrementStatNumbers(u(numberEl));
        if (!entry.isIntersecting) return;
        observer.unobserve(entry.target);
      });
    });

    // Run
    if (this.numbers.length) {
      this.numbers.each(el => { observer.observe(el) });
    }
    if (this.lightboxItems.length) {
      Ten.initLightbox();
    }
  }

  static initLightbox() {
    const lightbox = GLightbox({
      selector: 'js-lightbox',
      descPosition: 'bottom',
      width: 800
    });
  }

  static incrementStatNumbers(numberEl) {
    const startValue = numberEl.data('start-value');
    const endValue = numberEl.data('end-value');
    const decimalPlaces = numberEl.data('decimal-places') || 0;

    const options = {
      startVal: startValue,
      decimalPlaces: decimalPlaces
    };

    const countUp = new CountUp(numberEl.nodes[0], endValue, options);
    countUp.start();
  }
}
