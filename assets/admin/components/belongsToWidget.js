export default class BelongsToWidget {
  constructor(relationType, searchType) {
    $(`.remote.search.dropdown.${relationType}`).dropdown({
      fields: {name: "title", value: "id"},
      apiSettings: {
        url: `/admin/search/${searchType}?q={query}&f=json`
      }
    });
  }
}
