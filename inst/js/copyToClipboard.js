$(document).on('click', '.btn-clipboard', function(event) {
  const $codeButton = $(this);
  const codeText = $codeButton.attr("text-to-copy")
  navigator.clipboard.writeText(codeText);
});

