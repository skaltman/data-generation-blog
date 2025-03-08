library(ellmer)
library(dotenv)
library(readr)

#' Reads a CSV string into R using `readr::read_csv()`
#'
#' @param csv_string A single string representing literal data in CSV format, able to be read by `readr::read_csv()`.
#' @return A tibble. 
read_csv_string <- function(csv_string) {
  read_csv(csv_string, show_col_types = FALSE)
}

chat <- chat_openai(
  model = "gpt-4o",
  system_prompt = read_lines(here::here("prompts/prompt-csv-string-tool.md"))
)

chat$register_tool(tool(
  read_csv_string,
  "Parses a string containing CSV formatted data and reads it into a data frame.",
  csv_string = type_string(
    "CSV string containing the data to be read."
  )
))

chat$chat("tax data by state, with three columns", echo = FALSE) 

