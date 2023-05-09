$(document).on("keydown", ".chat-prompt", function(e) {
  let $prompt = $(this)
  if ((e.keyCode == 10 || e.keyCode == 13) && (!e.shiftKey)) {
    e.preventDefault();

    // the following sets a timeout of 0.5 seconds
    // otherwise the full text is not captured when the user types too fast

    // change the bg-color to provide feedback.
    $prompt.addClass("bg-primary bg-opacity-25")

    setTimeout(function() {
      $prompt.removeClass("bg-primary bg-opacity-25")
      $(".chat-send-btn").click();
    }, 500);
  }
});
