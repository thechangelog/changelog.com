import chapterItem from "templates/chapterItem.hbs";

async function getAsByteArray(file) {
  return new Uint8Array(await readFile(file))
}

function readFile(file) {
  return new Promise((resolve, reject) => {
    // Create file reader
    let reader = new FileReader()

    // Register event listeners
    reader.addEventListener("loadend", e => resolve(e.target.result))
    reader.addEventListener("error", reject)

    // Read file
    reader.readAsArrayBuffer(file)
  })
}

export default class ChaptersWidget {
  constructor(type, $sponsors) {
    let $chapters = $(`.js-${type}_chapters`)
    if (!$chapters.length) return

    let $wavFileDropZone = $chapters.siblings(".js-wav-file")
    let $addChapterButton = $chapters.siblings(".js-add-chapter")

    $wavFileDropZone.on("dragover", function(event) {
      event.preventDefault()
      $wavFileDropZone.addClass("secondary")
    })
    .on("dragleave", function(event) {
      $wavFileDropZone.removeClass("secondary")
      event.preventDefault()
    })
    .on("drop", async function(event) {
      event.preventDefault()

      let file = event.originalEvent.dataTransfer.items[0]

      if (file.type.match(/audio\/(x-)?wav/)) {
        $wavFileDropZone.removeClass("transition").addClass("loading")

        let byteFile = await getAsByteArray(file.getAsFile())

        let wav = new wavefile.WaveFile()

        wav.fromBuffer(byteFile)

        let markers = wav.listCuePoints()

        // TODO think of some conditions in which this won't happen
        if (true) {
          $chapters.empty()

          markers.forEach((marker, index) => {
            let name = marker.label
            let start = Math.round((marker.position / 1000) * 1000) / 1000
            let end = Math.round((marker.end / 1000) * 1000) / 1000
            let link = ""

            if ($sponsors.length) {
              let sponsorNameMatch = name.match(/Sponsor:\s(.*)/)

              if (sponsorNameMatch) {
                let sponsorItem = $sponsors.find(`input[value='${sponsorNameMatch[1]}']`).parents(".item")
                sponsorItem.find("input[name*=starts_at]").val(start)
                sponsorItem.find("input[name*=ends_at]").val(end)
                link = sponsorItem.find("input[name*=link_url]").val()
              }
            }

            let context = {
              index: index,
              type: type,
              title: name,
              starts_at: start,
              ends_at: end,
              link: link
            }

            $chapters.append(chapterItem(context))
          })
        }

        $wavFileDropZone.removeClass("loading")
      }
    })

    $addChapterButton.on("click", function() {
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
