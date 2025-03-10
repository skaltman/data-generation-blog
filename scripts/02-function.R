library(ellmer)

generate_data <- function(data_description) {
  chat <- chat_openai(
    model = "gpt-4o",
    system_prompt = readr::read_lines(here::here("prompts/prompt.md"))
  )

  csv_string <- chat$chat(data_description, echo = FALSE) 

  readr::read_csv(csv_string, show_col_types = FALSE)
}

df <- generate_data("tax data by state, with three columns")
print(df)
