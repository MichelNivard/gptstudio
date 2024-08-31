# create_temp_app_file creates a valid R script

    Code
      content
    Output
      [1] "ide_colors <- list(editor_theme = \"textmate\", editor_theme_is_dark = FALSE)"                                                                        
      [2] "      ui <- gptstudio:::mod_app_ui('app', ide_colors, 'https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.10.0/build/styles/github-dark.min.css')"
      [3] "      server <- function(input, output, session) {"                                                                                                   
      [4] "          gptstudio:::mod_app_server('app', ide_colors)"                                                                                              
      [5] "      }"                                                                                                                                              
      [6] "      shiny::shinyApp(ui, server)"                                                                                                                    

