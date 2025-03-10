library(ellmer)

# Replace chat_openai() with a different chat_* function to switch LLM providers
chat <- chat_openai(
  model = "gpt-4o",
  system_prompt = 
    "Generate tabular data based on the user's request. Limit the data to 10 rows unless the user specifically requests more."
)

chat$chat("Ask what kind of data the user wants to generate.", echo = TRUE) 
live_console(chat, quiet = TRUE) 