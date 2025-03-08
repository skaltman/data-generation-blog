library(tidyverse)
library(ellmer)
library(dotenv)
library(shiny)
library(bslib)
library(readr)
library(ggplot2)
library(DT)
library(shinychat)

ui <- page_sidebar(
  title = "LLM Data Generator",
  sidebar = sidebar(
    chat_ui("chat", height = "100%", fill = TRUE),
    downloadButton("btn_download", "Download CSV")
  ),
  useBusyIndicators(),
  card(
    card_header("Data"),
    dataTableOutput("data_table")
  ),
  card(
    card_header("Plot data"),
    plotOutput("plot")
  )
)

server <- function(input, output, session) {

  # Reactive values for the data and plot
  data_rv <- reactiveVal()
  plot_rv <- reactiveVal()

  #' Reads a CSV string into R using `readr::read_csv()`
  #'
  #' @param csv_string A single string representing literal data in CSV format, able to be read by `readr::read_csv()`.
  #' @return A tibble. 
  read_csv_string <- function(csv_string) {
    print("here")
    df <- read_csv(csv_string, show_col_types = FALSE)
    data_rv(df)
  }

  #' Evaluates R code that simulates data.
  #'
  #' @param code A single string containing valid R code that generates data.
  #' @return A tibble. 
  create_data <- function(code) {
    tryCatch(
      {
        df <- eval(parse(text = code))
      },
      error = function(err) {
        stop(err)
      }
    )

    stopifnot(is.data.frame(df))

    data_rv(df)
  }

  #' Executes a string of R code creating a ggplot2
  #'
  #' @param plot_code A string containing valid R code that creates a ggplot2 that plots a data framed named df
  #' @return A ggplot2 object. 
  plot_data <- function(plot_code) {
    df <- data_rv()
    
    p <- eval(parse(text = plot_code))

    plot_rv(p)
  }
  
  chat <- chat_claude(
    system_prompt = read_lines("prompt-app-r-generation.md")
  )

  chat_append("chat", "Describe a data set.")

  observeEvent(input$chat_user_input, {
    stream <- chat$stream_async(input$chat_user_input)
    # chat_append("chat", stream)
  })

  chat$register_tool(tool(
    create_data,
    "Executes R code passed a string to create a dataframe.",
    code = type_string(
        "A string contained valid R code that generates data and creates a tibble. Only use functions from base R or the tidyverse packages."
    )
  ))

  chat$register_tool(tool(
    plot_data,
    "A function that executes code that visualizes a dataframe called `df`",
    plot_code = type_string(
      "A string containing valid R code that uses ggplot2 to visualize a dataframe named `df`."
    )
  ))

  output$btn_download <- downloadHandler(
    filename = glue::glue("data_{Sys.Date()}.csv"),
    content = function(con) {
      write.csv(data_rv(), con)
    }
  )

  output$data_table <- renderDT({
    data_rv()
  })

  output$plot <- renderPlot({
    plot_rv()
  })

}

shinyApp(ui, server)