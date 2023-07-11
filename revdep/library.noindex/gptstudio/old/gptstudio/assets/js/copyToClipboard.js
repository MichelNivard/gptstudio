// listener for clipboard button click
// gpt-created
$(document).on('click', '.btn-clipboard', function(event) {

  // get the parent div and next pre tag
  const parentDiv = $(this).closest('div');
  const preTag = parentDiv.next('pre');

  // find code inside pre tag
  const codeTag = preTag.find('code');
  const code = codeTag.text();

  // create temp textarea and copy the code inside it
  const tempInput = $('<textarea>').val(code);
  $('body').append(tempInput);
  tempInput.select();
  document.execCommand('copy');
  tempInput.remove();

  // update clipboard button text
  const codeButton = $(this);
  const originalContent = codeButton.html();
  codeButton.html('Copied!');

  // reset clipboard button text after 1 second
  setTimeout(function() {
    codeButton.html(originalContent);
  }, 1000);
});

// gpt-created
function addCopyBtn() {
  // Get all the pre tags in the document that don't already have a copy button
  var preTags = $('pre:not(".hasCopyButton")');

  // Loop through all the pre tags
  preTags.each(function() {
    // Add class to indicate that the copy button has been added
    $(this).addClass('hasCopyButton');

    // Get the code element inside pre tag and its language class
    const codeTag = $(this).find('code');
    var language = codeTag.attr('class');
    if (language == undefined) {
      language = 'output';
    }

    // Create a div element with the copy button and language text
    // The svg icon was generated using FontAwesome library via R
    // fontawesome::fa("far fa-clipboard", margin_right = "0.2em")
    var div = $(`
    <div class="d-flex justify-content-between bg-dark" style="border-radius: 5px 5px 0 0">
      <p class="px-2 py-1 m-0 text-muted small">${language}</p>
      <button type="button" class="btn action-button btn-secondary btn-sm btn-clipboard shiny-bound-input" style="border-radius: 0 5px 0 0;">
        <svg aria-hidden="true" role="img" viewBox="0 0 384 512" style="height:1em;width:0.75em;vertical-align:-0.125em;margin-left:auto;margin-right:0.2em;font-size:inherit;fill:currentColor;overflow:visible;position:relative;"><path d="M280 64h40c35.3 0 64 28.7 64 64V448c0 35.3-28.7 64-64 64H64c-35.3 0-64-28.7-64-64V128C0 92.7 28.7 64 64 64h40 9.6C121 27.5 153.3 0 192 0s71 27.5 78.4 64H280zM64 112c-8.8 0-16 7.2-16 16V448c0 8.8 7.2 16 16 16H320c8.8 0 16-7.2 16-16V128c0-8.8-7.2-16-16-16H304v24c0 13.3-10.7 24-24 24H192 104c-13.3 0-24-10.7-24-24V112H64zm128-8a24 24 0 1 0 0-48 24 24 0 1 0 0 48z"/></svg>Copy
      </button>
    </div>
    `);

    // Insert the div with the copy button and language text before the pre tag
    $(this).before(div);
  });
}


$(document).on('shiny:inputchanged', function(event) {
  addCopyBtn();
});
