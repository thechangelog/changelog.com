import Sortable from "sortablejs";
import chapterItem from "templates/chapterItem.hbs";

export default class ChaptersWidget {
	constructor(type) {
		let $chapters = $(`.js-${type}_chapters`)
		console.log($chapters)
		if (!$chapters.length) return

		Sortable.create($chapters[0])

		$chapters.siblings(".js-add-chapter").on("click", function() {
			let context = {
			  index: $chapters.find(".item").length,
			  type: type
			}

			$chapters.append(chapterItem(context))
		})

		$chapters.on("click", ".js-remove", function(event) {
		  let $clicked = $(this)
		  let $member = $clicked.closest(".item")

		  if ($member.hasClass("persisted")) {
		    $clicked.children("input").val(true)
		    $member.hide()
		  } else {
		    $member.remove()
		  }
		})
	}
}
