$('pre').each(function() {
  const $codeChunk = $(this);
  const $copyButton = $('<button>').text('Copy');
  $codeChunk.append($copyButton);

/*
  $copyButton.on('click', function() {
    const codeText = $codeChunk.text();
    navigator.clipboard.writeText(codeText);
  });

*/
});

