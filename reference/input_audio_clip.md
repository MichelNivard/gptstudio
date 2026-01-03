# An audio clip input control that records short audio clips from the microphone

An audio clip input control that records short audio clips from the
microphone

## Usage

``` r
input_audio_clip(
  id,
  record_label = "Record",
  stop_label = "Stop",
  reset_on_record = TRUE,
  mime_type = NULL,
  audio_bits_per_second = NULL,
  show_mic_settings = TRUE,
  ...
)
```

## Arguments

- id:

  The input slot that will be used to access the value.

- record_label:

  Display label for the "record" control, or NULL for no label. Default
  is 'Record'.

- stop_label:

  Display label for the "stop" control, or NULL for no label. Default is
  'Record'.

- reset_on_record:

  Whether to reset the audio clip input value when recording starts. If
  TRUE, the audio clip input value will become NULL at the moment the
  Record button is pressed; if FALSE, the value will not change until
  the user stops recording. Default is TRUE.

- mime_type:

  The MIME type of the audio clip to record. By default, this is NULL,
  which means the browser will choose a suitable MIME type for audio
  recording. Common MIME types include 'audio/webm' and 'audio/mp4'.

- audio_bits_per_second:

  The target audio bitrate in bits per second. By default, this is NULL,
  which means the browser will choose a suitable bitrate for audio
  recording. This is only a suggestion; the browser may choose a
  different bitrate.

- show_mic_settings:

  Whether to show the microphone settings in the settings menu. Default
  is TRUE.

- ...:

  Additional parameters to pass to the underlying HTML tag.

## Value

An audio clip input control that can be added to a UI definition.
