import { u } from 'umbrellajs';
import { CountUp } from 'countup.js';

export default class Ten {
  constructor() {
    // Elements
    this.numbers = u('.js-increment');

    // Run
    if (this.numbers.length) {
      console.log(this.endValue);
      numbers.forEach(numberEl => {
        Ten.animateNumbers(numberEl);
      });
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
    const countUp = new CountUp(numberEl, endValue, options);

    // TODO: Start counting once element is in view
    countUp.start();
    
    // const observer = new IntersectionObserver((entry, observer) => {
    //   console.log('entry:', entry);
    //   console.log('observer:', observer);
    // });

    // observer.observe(numberEl);
  }
}
