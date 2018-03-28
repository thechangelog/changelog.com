import { u } from "umbrellajs";

// Just like umbrella's `serialize`, but with file upload support
u.prototype.toFormData = function() {
  let data = new FormData();

  Array.from(this.first().elements).forEach((el) => {
    if (!el.name || el.disabled) return;
    if (/(checkbox|radio)/.test(el.type) && !el.checked) return;

    if (el.type === "file")
      Array.from(el.files).forEach((f) => { data.append(el.name, f); });
    else if (el.type === "select-multiple")
      u(el.options).each((o) => { if (o.selected) data.append(el.name, o.value); });
    else
      data.append(el.name, el.value);
  });

  return data;
};
