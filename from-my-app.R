library(ellmer)
library(dotenv)


#' Reads in a CSV from a string.
#'
#' @param csv_string A string of representing CSV data.
#' @returns A tibble
preprocess_csv <- function(csv_string) {
  csv_string <- gsub("\\\\n", "\n", csv_string)
  csv_string
  # readr::read_csv(text = csv_string) |> tibble::as_tibble()
}

chat <- chat_openai(
  model = "gpt-4o",
  system_prompt = readr::read_lines("prompt.md")
)

# Give the chatbot the ability to play a sound.
#
# Created using `elmer::create_tool_metadata(play_sound)`
chat$register_tool(tool(
  preprocess_csv,
  "Turns a CSV string into a tibble.",
  csv_string = type_string(
    "A string representing data in a CSV. Must be compatible with the R function readr::read_csv()."
  )
))

chat$chat("Begin", echo = TRUE) # Jump-start the conversation
live_console(chat, quiet = TRUE) # Continue the conversation