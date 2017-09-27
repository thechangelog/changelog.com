export default class BelongsToWidget {
  constructor(relationType, searchType) {
    let noResultsMessage = function() {
      switch (searchType) {
        case "person":
          return "<a href='/admin/people/new' target='_blank'>Add a Person</a>";
          break;
        case "news_source":
          return "<a href='/admin/news/sources/new' target='_blank'>Add a Source</a>";
          break
      }
    }

    $(`.remote.search.dropdown.${relationType}`).dropdown({
      fields: {name: "title", value: "id"},
      apiSettings: {
        url: `/admin/search/${searchType}?q={query}&f=json`,
        cache: false
      },
      saveRemoteData: false,
      message: {
        noResults: noResultsMessage()
      }
    });
  }
}
