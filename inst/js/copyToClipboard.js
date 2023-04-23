$(document).on('click', '.btn-clipboard', function(event) {
  const $codeButton = $(this);
  const codeText = $codeButton.attr("text-to-copy")
  const btnId = $codeButton.attr("class-input-value")
  navigator.clipboard.writeText(codeText); // works in browser and local
  Shiny.setInputValue(btnId, codeText, {priority: "event"}) // works in RStudio
});

