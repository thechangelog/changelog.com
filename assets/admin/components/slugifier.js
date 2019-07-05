export default class Slugifier {
  constructor(fromSel, toSel) {
    this.$from = $(fromSel);
    this.$to = $(toSel);

    this.$from.on("blur", $.proxy(this.slugify, this));
  }

  slugify(event) {
    if (this.$to.val() !== "") return;
    this.$to.val(this.stringToSlug(this.$from.val()));
  }

  stringToSlug(string) {
    return string.toLowerCase().replace(/[^\w\s]+/g, "").replace(/\s+/g, "-");
  }
}
