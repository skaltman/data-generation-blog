library(ellmer)
library(dotenv)

# Step 3 -- add tool calling
# This result is actually pretty good, and we could make it even better by writing a longer prompt. 
# But one disadvantage is that the LLM is just giving us back text. If we're simulating large amounts of data, this is going to be 
# frustrating. We might also want the code that creates the data for reproducibility purposes. 
# we could just ask the LLM to generate us some code, but then we would still need to run it ourselves and test it. 
# Let's use tool calling to have the LLM write out the data to an R object/file and give us the code necessary to generate the data. 

# we need to do things:
# create a function -- a "tool" -- that creates the data we want
# pretend like a human is going to input something into the function
# then, we register the tool so that the LLM knows about it

# Let write the function first. 
# this is pretty much the same as writing a function for another person, except you want to think about the types of inputs the LLM can and 
# is good at providing. The work of the LLM is going into figuring out _how_ to call your function, just like a human would, instead of generating
# the output itslef. 
# this has a couple advantages. for one, it gives you the programmer more control over the LLM's outputs. you can define the kind of inputs and outputs
# taht are ok, setting up guardraisl within your function just like you would do when writing a function that humans would use.
# for examples, for our function will want to check the code creates a valid tibble of data, and error if not. 

#' Plays a sound effect.
#'
#' @param code_string A string of R code that generates 
#' @returns NULL
generate_data <- function(code_string) {

  tryCatch(
    {
      print("in the try catch")
      # Try it to see if it errors; if so, the LLM will see the error
      dbExecute(conn, query)
      print("code executed")
    },
    error = function(err) {
      print("in the error")
      # append_output("> Error: ", conditionMessage(err), "\n\n")
      stop(err)
    }
  )

  if (!is.null(query)) {
    df <- dbGetQuery(conn, "SELECT * FROM data")
    data(df)
    end <- Sys.time()
    print(start - end)
    return(query)
  }
}

chat <- chat_openai(
  model = "gpt-4o",
  system_prompt = "Generate tabular data based on the user's request."
)

# Give the chatbot the ability to play a sound.
#
# Created using `elmer::create_tool_metadata(play_sound)`
# chat$register_tool(tool(
#   play_sound,
#   "Plays a sound effect.",
#   sound = type_string(
#     "Which sound effect to play. Options are 'correct', 'incorrect', 'you-win'. Defaults to 'correct'.",
#     required = FALSE
#   )
# ))

chat$chat("Begin", echo = TRUE) # Jump-start the conversation
live_console(chat, quiet = TRUE) # Continue the conversation