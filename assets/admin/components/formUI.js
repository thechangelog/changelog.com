import autosize from "autosize";

export default class FormUI {
  static init() {
    autosize($("textarea:not(.scroll)"));
    $("input[readonly]").popup({
      content: "Read-only because danger. Use the console if you really need to edit this.",
      variation: "very wide"
    });
    $(".ui.dropdown:not(.link)").dropdown();
    $(".ui.checkbox").checkbox();
    $(".ui.button, [data-popup=true]").popup();
    $(".use-url").on("click", function() {
      $(this)
        .closest(".field")
          .find("input[type=file]")
            .attr("type", "text")
            .attr("placeholder", "https://example.com/image.jpg")
            .end()
          .find(".use-file")
            .show()
            .end()
          .end()
        .hide();
    });

    $(".use-file").on("click", function() {
      $(this)
        .closest(".field")
          .find("input[type=text]")
            .attr("type", "file")
            .end()
          .find(".use-url")
            .show()
            .end()
          .end()
        .hide();
    });

    $("input[mask='slug']").on("input", function(el) {
      let $input = $(this);

      try {
        let path = new URL($input.val()).pathname;

        if (path != "/") {
          let paths = path.split("/").filter(word => word.length > 1);
          let slug = paths[paths.length - 1];
          $input.val(slug);
        }
      } catch(error) {
        // console.log(error);
      }
    });
  }

  static refresh() {
    autosize($("textarea:not(.scroll)"));
    $("input[readonly]").popup("refresh");
    $(".ui.dropdown:not(.link)").dropdown("refresh");
    $(".ui.checkbox").checkbox("refresh");
    $(".ui.button, [data-popup=true]").popup("refresh");
  }
}
