# ui.R 
library(shiny)
library(shinydashboard)
library(shinyjs)
library(timevis)
library(rChartsCalmap)
library(htmlwidgets)
library(leaflet)

## ui.R ##
header <- dashboardHeader(title = tagList(icon("heart", class="heart-red"), "Wedding Planner"), titleWidth="250")

sidebar <- dashboardSidebar(width="250",
                            sidebarMenu(
                              # sidebarSearchForm("search_text", "search_btn"),
                              menuItem("Mission", tabName="mission", icon=icon("anchor")),
                              menuItem("Venue", tabName="venue", icon=icon("map-marker")),
                              menuItem("Timeline", tabName="timeline", icon=icon("calendar")),
                              menuItem("Guests", tabName="guests", icon=icon("users")),
                              menuItem("Budget", tabName="budget", icon=icon("dollar")),
                              menuItem("Other Stuff", tabName="other_stuff", icon=icon("question"))
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
    tabItem(tabName="mission",
      fluidRow(column(12, 
        box(title="Mission Statement", collapsible=TRUE, width=NULL, status="info",
          em(textOutput("mission_text")), br(), p("- Beck & Todd")
        )
      ))
    ),
    tabItem(tabName="venue",
      fluidRow(column(12, 
        box(title="Venues", collapsible=TRUE, width=NULL, status="info", 
          leafletOutput("venue_map")
        )
      ))
    ),
    tabItem(tabName="timeline",
      fluidRow(column(12, 
        tabBox(title="Timelines", width=NULL, 
          tabPanel("Timeline", value="timeline_tab",
            timevisOutput("timeline_viz"),
            fluidRow(column(12, 
              actionButton("timeline_add", "Add Item", icon=icon("plus")),
              actionButton("timeline_save", "Save Timeline", icon=icon("save"))
            ))
          ),
          tabPanel("Calendar", value="calendar_tab",
            fluidRow(column(12,
              actionButton("cal_prev", "", icon=icon("arrow-left")),               
              actionButton("cal_next", "", icon=icon("arrow-right"))               
            )), br(),
            calheatmapOutput("calendar_viz"),
            div(id="test")
          )
        )
      ))
    ),
    tabItem(tabName="guests",
      fluidRow(
        box(title="What-if Filters", collapsible=TRUE, width=7, status="info",
          uiOutput("guest_rel"),
          uiOutput("guest_likely"),
          checkboxInput("guest_plus_ones", "Include Plus Ones", value=TRUE),
          conditionalPanel("input.guest_plus_ones==1", numericInput("guest_plus_one_percent", "", value=100, min=0, max=100, width="100px")),
          checkboxInput("guest_child", "Include Children", value=TRUE),
          conditionalPanel("input.guest_child==1", numericInput("guest_child_percent", "", value=100, min=0, max=100, width="100px"))
        ),
        valueBoxOutput("guest_count", width=5) 
      ),
      fluidRow(column(12,
        box(title="Guest List", collapsible=TRUE, width=NULL, status="info",
          div(style="font-size:80%;", DT::dataTableOutput("guest_tbl"))
        )
      ))
    ),
    tabItem(tabName="budget",
            "budget"
    ),
    tabItem(tabName="other_stuff",
            "other stuff"
    )
  )
)

ui <- dashboardPage(title = "Wedding Planner", header, sidebar, body, skin="blue")

