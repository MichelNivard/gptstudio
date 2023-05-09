$(document).ready(function() {
  $(".chat-prompt").keydown(function(e) {
    if ((e.keyCode == 10 || e.keyCode == 13) && (e.ctrlKey || e.metaKey))
      $(".chat-send-btn").click();
  });
});
