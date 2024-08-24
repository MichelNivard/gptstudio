#' An audio clip input control that records short audio clips from the
#' microphone
#'
#' @param id The input slot that will be used to access the value.
#' @param record_label Display label for the "record" control, or NULL for no
#'   label. Default is 'Record'.
#' @param stop_label Display label for the "stop" control, or NULL for no label.
#'   Default is 'Record'.
#' @param reset_on_record Whether to reset the audio clip input value when
#'   recording starts. If TRUE, the audio clip input value will become NULL at
#'   the moment the Record button is pressed; if FALSE, the value will not
#'   change until the user stops recording. Default is TRUE.
#' @param mime_type The MIME type of the audio clip to record. By default, this
#'   is NULL, which means the browser will choose a suitable MIME type for audio
#'   recording. Common MIME types include 'audio/webm' and 'audio/mp4'.
#' @param audio_bits_per_second The target audio bitrate in bits per second. By
#'   default, this is NULL, which means the browser will choose a suitable
#'   bitrate for audio recording. This is only a suggestion; the browser may
#'   choose a different bitrate.
#' @param show_mic_settings Whether to show the microphone settings in the
#'   settings menu. Default is TRUE.
#' @param ... Additional parameters to pass to the underlying HTML tag.
#'
#' @return An audio clip input control that can be added to a UI definition.
#' @export
#'
#' @importFrom htmltools tag tags tagList div
#' @importFrom shiny icon
input_audio_clip <- function(
    id,
    record_label = "Record",
    stop_label = "Stop",
    reset_on_record = TRUE,
    mime_type = NULL,
    audio_bits_per_second = NULL,
    show_mic_settings = TRUE,
    ...) {
  # Create the settings menu
  settings_menu <- if (show_mic_settings) {
    tag("av-settings-menu", list(
      slot = "settings",
      div(
        class = "btn-group",
        tags$button(
          class = "btn btn-sm btn-secondary dropdown-toggle px-3 py-2",
          type = "button",
          `data-bs-toggle` = "dropdown",
          icon("gear", class = "fw")
        ),
        tags$ul(
          class = "dropdown-menu",
          tags$li(
            class = "mic-header",
            tags$h6("Microphone", class = "dropdown-header")
          )
          # Microphone items will go here
        )
      )
    ))
  } else {
    tag("av-settings-menu", list(
      slot = "settings",
      div(
        class = "btn-group",
        tags$ul(
          class = "dropdown-menu",
          tags$li(
            class = "mic-header",
            tags$h6("Microphone", class = "dropdown-header")
          )
          # Microphone items will go here
        )
      )
    ))
  }

  # Create the recording controls
  recording_controls <- div(
    class = "btn-group",
    slot = "recording-controls",
    `aria-label` = "Recording controls",
    tags$button(
      class = "record-button btn btn-secondary px-3 mx-auto",
      style = "display: block;",
      tagList(
        div(
          style = "display: inline-block; background-color: red; width: 1rem; height: 1rem; border-radius: 100%; position: relative; top: 0.175rem; margin-right: 0.3rem;" # nolint
        ),
        record_label
      )
    ),
    tags$button(
      class = "stop-button btn btn-secondary px-3 mx-auto",
      style = "display: block;",
      tagList(
        div(
          style = "display: inline-block; background-color: currentColor; width: 1rem; height: 1rem; position: relative; top: 0.175rem; margin-right: 0.3rem;" # nolint
        ),
        stop_label
      )
    )
  )

  # Create the main audio-clipper tag
  tag("audio-clipper", list(
    id = id,
    class = "shiny-audio-clip",
    `data-reset-on-record` = if (reset_on_record) "true" else "false",
    `data-mime-type` = mime_type,
    `data-audio-bits-per-second` = audio_bits_per_second,
    multimodal_dep(),
    settings_menu,
    recording_controls,
    ...
  ))
}

#' Create HTML dependency for multimodal component
#'
#' @importFrom htmltools htmlDependency
multimodal_dep <- function() {
  htmlDependency(
    name = "multimodal",
    version = "0.0.1",
    package = "shinymedia",
    src = system.file("dist", package = "gptstudio"),
    script = "index.js",
    stylesheet = "index.css"
  )
}
