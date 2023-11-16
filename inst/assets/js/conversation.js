$(document).on('click', ".multi-click-input", function(event) {
    let shinyInputId = $(this).attr("shiny-input-id")
    let value = $(this).attr("value")

    Shiny.setInputValue(shinyInputId, value, {priority: "event"});
})
