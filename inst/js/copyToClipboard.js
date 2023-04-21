$('pre').each(function() {
  const $codeChunk = $(this).css({
    "border-radius": "0 0 5px 5px" // rounded at bottom
  });

  let $language = $codeChunk.children("code").attr("class")
  if (typeof $language === "undefined") {
    $language = "output"
  }
  const $languageP = $('<p>').text($language).addClass("px-2 py-1 m-0 text-muted small")

  const $copyButton = $('<button>')
    .text('Copy')
    .addClass('btn btn-secondary btn-sm')
    .css({
      "border-radius": "0 5px 0 0" // rounded at top right
    });

  const $buttonDiv = $('<div>')
    .addClass("d-flex justify-content-between bg-dark")
    .append($languageP)
    .append($copyButton)
    .css({
      "border-radius": "5px 5px 0 0" // rounded at top
    })

  $codeChunk.before($buttonDiv);


  $copyButton.on('click', function() {
    const codeText = $codeChunk.text();
    navigator.clipboard.writeText(codeText);
  });


});
