library(ellmer)
library(dotenv)
library(tidyverse)

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

  current_time <- format(Sys.time(), "%Y-%m-%d_%H:%M:%S")
  file_df <- glue::glue("data-{current_time}")
  write_csv(df, file_df)
}

chat <- chat_openai(
  model = "gpt-4o",
  system_prompt = read_lines(here::here("prompts/prompt-r-generation.md"))
)

chat$register_tool(tool(
  create_data,
  "Executes R code passed a string to create a dataframe.",
  code = type_string(
      "A string contained valid R code that generates data and creates a tibble. Only use functions from base R or the tidyverse packages."
  )
))

chat$chat("phone sales data in 2010", echo = FALSE) 
