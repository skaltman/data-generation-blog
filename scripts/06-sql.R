library(ellmer)
library(dotenv)
library(tidyverse)
library(duckdb)
library(DBI)

# Create in-memory database
con <- dbConnect(duckdb(), dbdir = ":memory:", read_only = FALSE)

#' Executes a SQL query to create a new table with simulated data
#'
#' @param query A DuckDB SQL query; must be a CREATE statement.
#' @returns A string representing the query
create_data <- function(query) {
  tryCatch(
    {
      dbExecute(con, query)
    },
    error = function(err) {
      stop(err)
    }
  )

  query
}

chat <- chat_openai(
  model = "gpt-4o",
  system_prompt = read_lines(here::here("prompts/prompt-sql.md"))
)

chat$register_tool(tool(
  create_data,
  "Executes a DuckDB SQL query that creates a new table with simulated data.",
  query = type_string(
      "A string contained valid DuckDB SQL that generates data. The query must be a CREATE statement."
  )
))

chat$chat("financial transaction data", echo = FALSE) 

# See what table was created
dbListTables(con)

# Disconnect when done
# dbDisconnect(con)
