import autosize from "autosize";

export default class FormUI {
  static init() {
    autosize($("textarea:not(.scroll)"));
    $("input[readonly]").popup({
      content: "Read-only because danger. Use the console if you really need to edit this.",
      variation: "very wide"
    });
    $(".ui.dropdown").dropdown();
    $(".ui.checkbox").checkbox();
    $(".ui.button, [data-popup=true]").popup();
  }

  static refresh() {
    autosize($("textarea:not(.scroll)"));
    $("input[readonly]").popup("refresh");
    $(".ui.dropdown").dropdown("refresh");
    $(".ui.checkbox").checkbox("refresh");
    $(".ui.button, [data-popup=true]").popup("refresh");
  }
}
