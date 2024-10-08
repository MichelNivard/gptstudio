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
          bsicons::bs_icon("gear")
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
    class = "d-flex flex-column align-items-center",
    slot = "recording-controls",
    `aria-label` = "Recording controls",
    div(
      class = "btn-group m-3",
      tags$button(
        class = "record-button btn-sm btn-secondary rounded-circle p-0 mx-2",
        style = "width: 2.5rem; height: 2.5rem; display: flex; justify-content: center; align-items: center;", # nolint
        div(
          style = "background-color: red; width: 1.5rem; height: 1.5rem; border-radius: 50%; position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);" # nolint
        )
      ),
      tags$button(
        class = "stop-button btn-sm btn-secondary rounded-circle p-0 mx-2",
        style = "width: 3rem; height: 3rem; display: flex; justify-content: center; align-items: center;", # nolint
        div(
          style = "background-color: currentColor; width: 1.5rem; height: 1.5rem; position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);" # nolint
        )
      )
    ),
    div(
      class = "d-flex justify-content-between w-100",
      div(class = "text-center mx-2", record_label),
      div(class = "text-center mx-2", stop_label)
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
multimodal_dep <- function() {
  htmltools::htmlDependency(
    name = "gptstudio",
    version = "0.4.0",
    package = "gptstudio",
    src = "assets",
    script = "js/audio-recorder.js",
    stylesheet = "css/audio-recorder.css"
  )
}
