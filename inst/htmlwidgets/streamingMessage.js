HTMLWidgets.widget({

  name: 'streamingMessage',

  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(x) {

        // TODO: code to render the widget, e.g.
        el.innerHTML = x.message;
        el.classList.add("d-none"); // to start hidden
        el.classList.add("streaming-message"); // to be captured in a message handler

      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});

// This is independent from the HTMLwidget code.
// It will only run inside projects with the shiny JS bindings (aka shiny apps).
Shiny.addCustomMessageHandler(
  type = 'render-stream', function(message) {
    const $el = $('.streaming-message')
    $el.removeClass('d-none')


    const $userMessage = $el.find('.user-message-wrapper')
    const $assistantMessage = $el.find('.assistant-message-wrapper')

    if ($userMessage.html().length == 0) {
      $userMessage.html($.parseHTML(message.user))
    }

    $assistantMessage.html($.parseHTML(message.assistant))

});

