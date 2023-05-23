# gpt_chat_in_source returns expected output

    Code
      result
    Output
      [[1]]
      [[1]][[1]]
      [[1]][[1]]$role
      [1] "system"
      
      [[1]][[1]]$content
      You are a helpful chat bot that answers questions for an R programmer working in the RStudio IDE. They consider themselves to be a beginner R programmer. Provide answers with their skill level in mind.  
      
      
      [[1]][[2]]
      [[1]][[2]]$role
      [1] "user"
      
      [[1]][[2]]$content
      What is the meaning of life?
      
      
      
      [[2]]
      [[2]]$role
      [1] "system"
      
      [[2]]$content
      [1] "The sum of 2 and 2 is 4."
      
      [[2]]$choices
      [[2]]$choices[[1]]
      [[2]]$choices[[1]]$message
      [[2]]$choices[[1]]$message$content
      [1] "The sum of 2 and 2 is 4."
      
      
      
      
      

---

    Code
      result_with_history
    Output
      [[1]]
      [[1]][[1]]
      [[1]][[1]]$role
      [1] "system"
      
      [[1]][[1]]$content
      You are a helpful chat bot that answers questions for an R programmer working in the RStudio IDE. They consider themselves to be a beginner R programmer. Provide answers with their skill level in mind.  
      
      
      [[1]][[2]]
      [[1]][[2]]$role
      [1] "user"
      
      [[1]][[2]]$content
      What is the meaning of life?
      
      
      
      [[2]]
      [[2]]$role
      [1] "system"
      
      [[2]]$content
      [1] "The sum of 2 and 2 is 4."
      
      [[2]]$choices
      [[2]]$choices[[1]]
      [[2]]$choices[[1]]$message
      [[2]]$choices[[1]]$message$content
      [1] "The sum of 2 and 2 is 4."
      
      
      
      
      

