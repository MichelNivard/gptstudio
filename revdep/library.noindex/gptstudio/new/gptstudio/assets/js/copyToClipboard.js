$(document).on('click', '.btn-clipboard', function(event) {

  // get the parent div of the parent div and next pre tag
  const parentDiv = $(this).closest('div').parent();
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
    var div = $(`
    <div class="d-flex justify-content-between bg-dark" style="border-radius: 5px 5px 0 0">
    <p class="px-2 py-1 m-0 text-muted small">${language}</p>
    <div>
        <button type="button" class="btn action-button btn-secondary btn-sm btn-clipboard shiny-bound-input ml-auto">
            <i class="fas fa-copy"></i> Copy
        </button>
    </div>
    </div>
    `);

    // Insert the div with the copy button and language text before the pre tag
    $(this).before(div);
  });
}


$(document).on('shiny:inputchanged', function(event) {
  addCopyBtn();
});
