$(document).on('click', '.btn-clipboard', function(event) {
  const $codeButton = $(this);
  $codeButton.text("Copied!")

  setTimeout(function() {
    $codeButton.text("Copy")
  }, 1000);
});

