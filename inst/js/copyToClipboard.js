$(document).on('click', '.btn-clipboard', function(event) {
  const $codeButton = $(this);
  const $originalContent = $codeButton.html()

  $codeButton.html("Copied!")

  setTimeout(function() {
    $codeButton.html($originalContent)
  }, 1000);
});

