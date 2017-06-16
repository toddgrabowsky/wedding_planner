library(shiny)
library(shinydashboard)
library(shinyjs)

## ui.R ##
header <- dashboardHeader(title = tagList(icon("heart"), "Wedding Planner"), titleWidth="250")

sidebar <- dashboardSidebar(width="250",
  sidebarMenu(
    # sidebarSearchForm("search_text", "search_btn"),
    menuItem("Timeline", tabName="timeline", icon=icon("calendar")),
    menuItem("Budget", tabName="budget", icon=icon("dollar")),
    menuItem("Guests", tabName="guests", icon=icon("users"))
    # menuItem("Item #3", tabName="item3", icon=icon("cube"),
    #          menuSubItem("Sub Item A", tabName="item3A"),
    #          menuSubItem("Sub Item B", tabName="item3B")
    # )
  )
)

body <- dashboardBody( 
  # add shiny js
  useShinyjs(),
  # link to custom CSS
  tags$link(rel="stylesheet", type="text/css", href="custom.css"),
  
  tabItems(
    tabItem(tabName="timeline",
      "timeline"
    ),
    tabItem(tabName="budget",
      "budget"
    ),
    tabItem(tabName="guests",
      "guests"
    )
  )
)

ui <- dashboardPage(header, sidebar, body, skin="blue")


server <- function(input, output, session) {
  runjs('
    var el2 = document.querySelector(".skin-blue");
    el2.className = "skin-blue sidebar-mini";
  ')
}

shinyApp(ui, server)

