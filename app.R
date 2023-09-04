library(shiny)
library(sass)

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
      class = "selections",
      div(
        "Button dropdown menu"
      ),
      div(
        "Slider"
      ),
      div(
        "Button"
      )
    ),

    div(class = "line"),

    div(
      class = "owners-count",
      "Text block"
    ),

    div(
      div("Table")
    ),

    div(
      class = "charts",
      div("Barcharts"),
      div("Piechart")
    )
  )
)

server <- function(input, output) {

}

shinyApp(ui = ui, server = server)