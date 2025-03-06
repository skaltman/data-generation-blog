library(ellmer)
library(dotenv)
library(shiny)
library(bslib)
library(readr)
library(ggplot2)

ui <- page_sidebar(
  title = "LLM Data Generator",
  sidebar = sidebar(
    textAreaInput("data_description", "Describe the data you want to generate."),
    actionButton("btn_generate", "Generate data"),
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
  data_rv <- reactiveVal()
  plot_rv <- reactiveVal()

  #' Reads a CSV string into R using `readr::read_csv()`
  #'
  #' @param csv_string A single string representing literal data in CSV format, able to be read by `readr::read_csv()`.
  #' @return A tibble. 
  read_csv_string <- function(csv_string) {
    df <- read_csv(csv_string, show_col_types = FALSE)
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
  
  chat <- chat_openai(
    model = "gpt-4o",
    system_prompt = read_lines("prompt-app.md")
  )

  chat$register_tool(tool(
    read_csv_string,
    "Parses a string containing CSV formatted data and reads it into a data frame.",
    csv_string = type_string(
      "CSV string containing the data to be read."
    )
  ))

  chat$register_tool(tool(
    plot_data,
    "A function that executes code that visualizes a dataframe called `df`",
    plot_code = type_string(
      "A string containing valid R code that uses ggplot2 to visualize a dataframe named `df`."
    )
  ))


  observeEvent(input$btn_generate, {
    chat$chat(input$data_description)
  })

  output$btn_download <- downloadHandler(
    filename = glue::glue("data_{Sys.Date()}.csv"),
    content = function(con) {
      write.csv(data_rv(), con)
    }
  )

  output$data_table <- renderDataTable({
    data_rv()
  })

  output$plot <- renderPlot({
    plot_rv()
  })
}

shinyApp(ui, server)