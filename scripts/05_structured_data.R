library(ellmer)

chat <- chat_openai(
  model = "gpt-4o",
  system_prompt = "Given a description, generate structured data."
)

response <- 
  chat$chat(
    "data with 2 columns, x and y. x should have a normal distribution and y be random strings.",
    echo = FALSE
  )

df <-
  chat$extract_data(
    df,
    type = type_array(
      items = type_object(
        x = type_number(),
        y = type_string()
      )
    )
  )
