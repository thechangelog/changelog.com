export default class BelongsToWidget {
  constructor(relationType, searchType) {
    let noResultsMessage = function () {
      switch (searchType) {
        case "person":
          return "<a href='/admin/people/new' target='_blank'>Add a Person</a>";
          break;
        case "news_source":
          return "<a href='/admin/news/sources/new' target='_blank'>Add a Source</a>";
          break;
        case "sponsor":
          return "<a href='/admin/sponsors/new' target='_blank'>Add a Sponsor</a>";
          break;
      }
    };

    let $container = $(`.remote.search.dropdown.${relationType}`);
    let $field = $container.closest(".field");

    let name = searchType == "person" ? "extended_title" : "title";

    $container.dropdown({
      fields: { name: name, value: "id" },
      apiSettings: {
        url: `/admin/search/${searchType}?q={query}&f=json`,
        cache: false
      },
      saveRemoteData: false,
      message: {
        noResults: noResultsMessage()
      }
    });

    $field.on("click", ".js-clear", function (event) {
      event.preventDefault();
      $container.dropdown("clear");
      $container.dropdown("hide");
    });
  }
}
