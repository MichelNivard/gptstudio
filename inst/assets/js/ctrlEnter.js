$(document).ready(function() {
  $("#app-chat-prompt-chat_input").keydown(function(e) {
    if ((e.keyCode == 10 || e.keyCode == 13) && (e.ctrlKey || e.metaKey))
      $("#app-chat-prompt-chat").click();
  });
});
