
# Load necessary libraries
library(elmer)
library(dotenv)

# Step 1: Define Tool Functions

# Function to simulate a numeric variable
simulate_numeric <- function(n, mean, sd) {
  rnorm(n, mean, sd)
}

# Function to simulate a categorical variable
simulate_categorical <- function(n, levels) {
  sample(levels, n, replace = TRUE)
}

# Step 2: Initialize the Elmer Chat and Register Tools

# Create a chat object
chat <- chat_openai(
  model = "gpt-4o-mini",
  system_prompt = "You are a data scientist who understands user descriptions and simulates datasets."
)

# Register the tools
chat$register_tool(tool(
  simulate_numeric,
  .description = "Simulate a numeric variable with a given mean and standard deviation.",
  n = type_integer("Number of observations"),
  mean = type_number("Mean of the distribution"),
  sd = type_number("Standard deviation of the distribution")
))

chat$register_tool(tool(
  simulate_categorical,
  .description = "Simulate a categorical variable with given levels.",
  n = type_integer("Number of observations"),
  levels = type_array("Levels of the categorical variable", items = type_string())
))

# Step 3: Use the Chat for Tool Invocation Based on User Description

# Function to handle user description and simulate data
simulate_data_from_description <- function(description) {
  response <- chat$chat(description)
  print(response)
}

# Example user description
user_description <- "I need a dataset with 1000 entries. Include a numeric variable 'height' with an average of 170 and sd of 10, and a categorical variable 'status' with levels 'Single', 'Married', and 'Divorced'."

# Call the function with the user's description
simulate_data_from_description(user_description)