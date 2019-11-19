import { u } from 'umbrellajs';
import { CountUp } from 'countup.js';
// import MicroModal from 'micromodal';

export default class Ten {
  constructor() {
    // Elements
    this.numbers = u('.js-increment');

    const observer = new IntersectionObserver(function(entries) {
      entries.forEach(entry => {
        let numberEl = u(entry.target);
        Ten.animateNumbers(u(numberEl));
        if (!entry.isIntersecting) return;
        observer.unobserve(entry.target);
      });
    });

    // Run
    if (this.numbers.length) {
      this.numbers.each(el => { observer.observe(el) });
    }
  }

  static animateNumbers(numberEl) {
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
