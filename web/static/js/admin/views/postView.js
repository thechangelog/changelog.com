export default class PostView {
  new() {
    $(".remote.search.dropdown").dropdown({
      fields: {name: "title", value: "id"},
      apiSettings: {
        url: `/admin/search?t=person&q={query}`
      }
    });
  }

  edit() {
    this.new()
  }
}
