library(shiny)
library(sass)
library(dplyr)
library(ggplot2)

owners <- read.csv("car_owners.csv", stringsAsFactors = FALSE)

owners$income_fct <- factor(owners$income, levels = c("Under $25", "$25 - $49",
                                                      "$50 - $74", "$75+"))

sass(
  sass::sass_file("styles/main.scss"),
  options = sass_options(output_style = "compressed"),
  output = "www/styles/sass.min.css"
)

ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles/sass.min.css"),
  # tags$script(src = "/scripts/index.js")
  ),
  div(
    h1(
      class = "header",
      "Car Owners"
    ),

    div(
      class = "inputs",
      div(
        class = "gender",
        selectInput(
          "gender", "Choose a gender group",
          choices = c("Female", "Male")
        )
      ),
      div(
        class = "age-slider",
        sliderInput(
          "age", "Select an age range",
          min = 18, max = 77, value = c(30, 50)
        )
      ),
      div(
        class = "results-btn",
        actionButton("go", "Get Results")
      )
    ),

    div(class = "line"),

    div(
      class = "count-table",
      div(
        class = "owners-count",
        textOutput("entries_text")
      ),

      div(
        class = "stats-table",
        dataTableOutput("entries_table")
      )
    ),

    div(
      class = "charts",
      plotOutput("bar_chart"),
      plotOutput("pie_chart")
    )
  )
)

server <- function(input, output) {
  
  ##### DATA PREPARATION ##################
  
  ### create the filtered data set
  
  owners_filtered <- eventReactive(input$go, {
    
    owners %>% filter(gender == input$gender,
                      age >= input$age[1],
                      age <= input$age[2]) %>%
      select(car_price, income, education, marital, income_fct)
    
    
  })
  
  ### compute the number of entries (owners) in the filtered data set
  
  entries <- eventReactive(input$go, {
    
    owners_filtered() %>% count()
    
  })
  
  ### create the data frame with the frequencies of the education variable
  ### (needed for the pie chart)
  
  frequencies <- eventReactive(input$go, {
    
    owners_filtered() %>% count(education)
    
  })
  
  frequencies_df <- eventReactive(input$go, {
    
    as.data.frame(frequencies())
    
  })
  
  ##### CREATE THE OUTPUT OBJECTS ##################
  
  ### print the text
  
  output$entries_text <- renderText({
    
    paste0("Number of owners: ", entries())
    
  })
  
  ### display the table
  
  output$entries_table <- renderDataTable(
    
    options = list(pageLength = 5),
    
    {
      
      owners_filtered()[,-5]
      
    } )
  
  ### plot the bar chart
  
  output$bar_chart <- renderPlot(
    
    {
      
      ggplot(owners_filtered(), aes(income_fct, car_price))+
        geom_bar(fill = "#85bff2", stat = "summary", fun = mean)+
        xlab("Income level")+
        ylab("Average car price")+
        labs(title = "Average Car Price by Income Level",
             subtitle = paste0("Gender: ", input$gender))+
        theme(plot.title = element_text(size = 17, hjust = 0.5, face = "bold"),
              plot.subtitle = element_text(size = 14, hjust = 0.5),
              panel.background = element_rect(fill = "white", colour = "black"))
      
      
    })
  
  
  ### plot the pie chart
  
  output$pie_chart <- renderPlot({
    
    ggplot(frequencies_df(), aes(x = "", y = n, fill = education))+
      geom_bar(stat = "identity")+
      coord_polar(theta = "y", start = 0)+
      labs(title = "Structure by Education Level",
           subtitle = paste0("Gender: ", input$gender))+
      theme(axis.title = element_blank(),
            axis.text = element_blank(),
            axis.ticks = element_blank(),
            panel.background = element_rect(fill = "white"),
            plot.title = element_text(size = 17, hjust = 0.5, face = "bold"),
            plot.subtitle = element_text(size = 14, hjust = 0.5))+
      scale_fill_brewer(palette = "Greens")+
      labs(fill = "Education")
    
    
  })
  
  
  
}

shinyApp(ui = ui, server = server)