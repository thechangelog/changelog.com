import chapterItem from "templates/chapterItem.hbs";
import { WaveFile } from "wavefile";

async function getAsByteArray(file) {
  return new Uint8Array(await readFile(file));
}

function readFile(file) {
  return new Promise((resolve, reject) => {
    // Create file reader
    let reader = new FileReader();

    // Register event listeners
    reader.addEventListener("loadend", (e) => resolve(e.target.result));
    reader.addEventListener("error", reject);

    // Read file
    reader.readAsArrayBuffer(file);
  });
}

export default class ChaptersWidget {
  constructor(type, $sponsors) {
    let $chapters = $(`.js-${type}_chapters`);
    if (!$chapters.length) return;

    let $wavFileDropZone = $chapters.siblings(".js-wav-file");
    let $addChapterButton = $chapters.siblings(".js-add-chapter");
    let $copyDataButton = $chapters.siblings(".js-copy-chapter-data");

    $wavFileDropZone
      .on("dragover", function (event) {
        event.preventDefault();
        $wavFileDropZone.addClass("secondary");
      })
      .on("dragleave", function (event) {
        $wavFileDropZone.removeClass("secondary");
        event.preventDefault();
      })
      .on("drop", async function (event) {
        event.preventDefault();

        let file = event.originalEvent.dataTransfer.items[0];

        if (file.type.match(/audio\/(x-)?wav/)) {
          $wavFileDropZone.removeClass("transition").addClass("loading");

          let byteFile = await getAsByteArray(file.getAsFile());
          let wav = new WaveFile();

          wav.fromBuffer(byteFile);

          let markers = wav.listCuePoints();

          // TODO think of some conditions in which this won't happen
          if (true) {
            $chapters.empty();

            markers.forEach((marker, index) => {
              let name = marker.label;
              let start = Math.round((marker.position / 1000) * 1000) / 1000;
              let end = Math.round((marker.end / 1000) * 1000) / 1000;
              let link = "";
              let image = "";

              if ($sponsors.length) {
                let sponsorNameMatch = name.match(/Sponsor:\s(.*)/);

                if (sponsorNameMatch) {
                  let sponsorItem = $sponsors
                    .find(`input[value='${sponsorNameMatch[1]}']`)
                    .parents(".item");
                  sponsorItem.find("input[name*=starts_at]").val(start);
                  sponsorItem.find("input[name*=ends_at]").val(end);
                  link = sponsorItem.find("input[name*=link_url]").val();
                }
              }

              let context = {
                index: index,
                count: index + 1,
                type: type,
                title: name,
                starts_at: start,
                ends_at: end,
                link: link,
                image: image
              };

              $chapters.append(chapterItem(context));
            });
          }

          $copyDataButton.trigger("click");
          $wavFileDropZone.removeClass("loading");
        }
      });

    $addChapterButton.on("click", function () {
      let context = {
        index: $chapters.find(".item").length,
        type: type
      };

      $chapters.append(chapterItem(context));
    });

    $copyDataButton.on("click", function () {
      $chapters.find(".item").each((index, item1) => {
        let title1 = $(item1).find("input[name*=title]");
        let image1 = $(item1).find("input[name*=image_url]");
        let link1 = $(item1).find("input[name*=link_url]");

        $(".js-audio_chapters")
          .find(".item")
          .each((index, item2) => {
            let title2 = $(item2).find("input[name*=title]");
            let image2 = $(item2).find("input[name*=image_url]");
            let link2 = $(item2).find("input[name*=link_url]");

            if (title2.val() == title1.val()) {
              image1.val(image2.val());
              link1.val(link2.val());
            }
          });
      });
    });

    $chapters.on("click", ".js-remove", function (event) {
      let $clicked = $(this);
      let $member = $clicked.closest(".item");

      if ($member.hasClass("persisted")) {
        $clicked.children("input").val(true);
        $member.hide();
      } else {
        $member.remove();
      }
    });
  }
}
