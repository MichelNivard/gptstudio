library(shiny)
library(shinyjs)
library(httr)
library(jsonlite)

audio_recorder_ui <- function(id) {
  ns <- NS(id)

  tagList(
    useShinyjs(),
    div(
      id = ns("recording-area"),
      actionButton(ns("startrec"), "Start Recording"),
      actionButton(ns("stoprec"), "Stop Recording"),
      tags$audio(id = ns("recorded_audio"), controls = TRUE)
    ),
    div(
      id = ns("timer"),
      style = "display: none;",
      "Recording time: ",
      tags$span(id = ns("time"), "0"),
      " seconds"
    )
  )
}

audio_recorder <- function(input, output, session) {
  observeEvent(input$startrec, {
    runjs(sprintf("
      navigator.mediaDevices.getUserMedia({ audio: true })
        .then(function(stream) {
          mediaRecorder = new MediaRecorder(stream);
          const chunks = [];

          const audioCtx = new AudioContext();
          const analyzer = audioCtx.createAnalyser();
          analyzer.fftSize = 256;
          const bufferLength = analyzer.frequencyBinCount;
          const dataArray = new Uint8Array(bufferLength);

          const startTime = Date.now();
          const timer = setInterval(function() {
            const elapsedTime = Math.round((Date.now() - startTime) / 1000);
            document.getElementById('%s').style.display = 'block';
            document.getElementById('%s').innerHTML = elapsedTime;
          }, 1000);

          mediaRecorder.start();

          mediaRecorder.addEventListener('dataavailable', event => {
            chunks.push(event.data);
          });

          const vadInterval = 50;
          let vadTimer;
          let lastVoiceTime = 0;
          const vadThreshold = 30;
          const vadBuffer = 5;
          let vadBufferCount = 0;
          const vadBufferMax = Math.floor((1000 / vadInterval) * vadBuffer);
          const stopRecording = () => {
            clearInterval(vadTimer);
            mediaRecorder.stop();
          };

          const dest = audioCtx.createMediaStreamDestination();
          analyzer.connect(dest);
          const source = audioCtx.createMediaStreamSource(stream);
          source.connect(analyzer);

          vadTimer = setInterval(function() {
            analyzer.getByteFrequencyData(dataArray);
            let sum = 0;
            for (let i = 0; i < bufferLength; i++) {
              sum += dataArray[i];
            }
            const average = sum / bufferLength;
            const level = Math.max(0, Math.min(100, average - vadThreshold));
            if (level > 0) {
              lastVoiceTime = Date.now();
              vadBufferCount = 0;
            } else {
              vadBufferCount++;
              if (vadBufferCount >=
                  vadBufferMax && Date.now() - lastVoiceTime >= 500) {
                stopRecording();
              }
            }
          }, vadInterval);

          mediaRecorder.addEventListener('stop', () => {
            clearInterval(timer);
            clearInterval(vadTimer);
            const blob = new Blob(chunks,
                                  { 'type' : 'audio/ogg; codecs=opus' });
            const url = URL.createObjectURL(blob);
            document.getElementById('%s').src = url;
          });
        });
    ", session$ns("timer"), session$ns("time"), session$ns("recorded_audio")))
  })

  observeEvent(input$stoprec, {
    cli::cli_inform("Stopping recording")
    runjs("
      if (mediaRecorder) {
        mediaRecorder.stop();
      }
    ")
  })
}


# Main app UI
ui <- fluidPage(
  audio_recorder_ui("recorder1"),
  hr(),
  h3("Transcription:"),
  verbatimTextOutput("transcription")
)

# Main app server function
server <- function(input, output, session) {
  callModule(audio_recorder, "recorder1")

  observeEvent(input$recorder1_stoprec, {
    # Ensure the recorded_audio input exists
    req(input$recorder1_recorded_audio)
    # Save the recorded audio as a file on the server
    audio_content <- input$recorder1_recorded_audio
    audio_filepath <- tempfile(fileext = ".ogg")
    writeBin(base64enc::base64decode(audio_content), audio_filepath)

    # Send the audio file to the Whisper ASR API
    openai_api_key <- "<your_openai_api_key>"
    res <- httr::POST(
      "https://api.openai.com/v1/engines/davinci-codex/completions",
      httr::add_headers(
        "Content-Type" = "application/json",
        "Authorization" = glue::glue("Bearer {openai_api_key}")
      ),
      body = jsonlite::toJSON(list(
        model = "whisper",
        prompt = "Transcribe the following audio:",
        audio = base64enc::base64encode(audio_filepath),
        max_tokens = 1000
      ), auto_unbox = TRUE),
      encode = "json"
    )

    # Check for errors and parse the transcription
    if (httr::http_error(res)) {
      stop("Error occurred during transcription:",
           httr::http_status(res)$message)
    } else {
      transcription <-
        jsonlite::fromJSON(
          httr::content(res, "text", encoding = "UTF-8")
          )$choices[[1]]$text
      output$transcription <- renderText(transcription)
    }
  })
}

shinyApp(ui, server)
