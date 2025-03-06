library(ellmer)
library(dotenv)

# Step 1 - setup
# Install ellmer and dotenv
# Add an API key for your LLM 

# Step 2 - create a basic chat with elmer
# we're going to outline how our script will work and then move back to the prompt
# first, we're going to just create a chat with ellmer and start the chat

# Use a chat_ function to start a chat. ellmer supports a variety of LLM providers, including OpenAI, Claude, and 
chat <- chat_openai(
  model = "gpt-4o",
  system_prompt = "Generate tabular data based on the user's request."
)

chat$chat("Ask what kind of data the user wants to generate.", echo = TRUE) # Jump-start the conversation
live_console(chat, quiet = TRUE) # Continue the conversation