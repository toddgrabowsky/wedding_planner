# server.R
library(shiny)
library(shinydashboard)
library(shinyjs)
library(googlesheets)
library(dplyr)
library(tidyr)
library(rChartsCalmap)
library(htmlwidgets)
library(leaflet)

shinyServer(function(input, output, session) {
  # code to collapse sidebar into icons
  runjs('
    var el2 = document.querySelector(".skin-blue");
    el2.className = "skin-blue sidebar-mini";
  ')
  
  sheet <- reactive(gs_title("Wedding Planner"))
  
  stored <- reactiveValues()
  
  mission <- reactive({
    withProgress(message="loading mission statement...", value=1, {
      mission <- sheet() %>% gs_read("mission") %>% data.frame
      mission <- paste0('"', mission[5, 1], '"')
    })
  })
  
  output$mission_text <- renderText({
    mission()
  })
  
  venues <- reactive({
    withProgress(message="loading timeline data...", value=1, {
      venues <- sheet() %>% gs_read("venues")
    })
  })
  
  output$venue_map <- renderLeaflet({
    leaflet() %>% 
      addProviderTiles(providers$CartoDB.Positron,
                       options = providerTileOptions(noWrap = TRUE)
      ) %>%
      addMarkers(lng = venues()$long, lat = venues()$lat, popup = venues()$popup, label = venues()$label)
  })
  
  timeline <- reactive({
    withProgress(message="loading timeline data...", value=1, {
      timeline <- sheet() %>% gs_read("timeline")
      names(timeline) <- c("content", "start", "title")
      timeline$id <- 1:nrow(timeline)
      timeline$end <- NA
      #timeline$type <- "point"
      stored$timeline <- timeline
      timeline %>%
        select(id, start, end, content, title)
    })
  })
  
  output$timeline_viz <- renderTimevis({
    df <- timeline()
    tv <- timevis(df, options=list(editable=TRUE)) %>%
      centerTime(Sys.time())
  })
  
  observeEvent(input$timeline_add, {
    showModal(
      modalDialog(
        title = "Add Item to Timeline",
        textInput("timeline_add_content", "Activity:"),
        dateInput("timeline_add_date", "Date:"),
        textInput("timeline_add_details", "Details:"),
        footer=tagList(modalButton("Cancel"), actionButton("timeline_add_btn", "Add"))
      )
    )
  })
  
  observeEvent(input$timeline_add_btn, {
    add <- list(id=nrow(stored$timeline)+1, start=input$timeline_add_date, end=NA, content=input$timeline_add_content, title=input$timeline_add_details)
    addItem(id="timeline_viz", data=add)
    removeModal()
    stored$timeline <- rbind(stored$timeline, add)
  })
  
  observeEvent(input$timeline_save, {
    tv_save <- stored$timeline
    filename <- paste0("timeline", Sys.time())
    withProgress(message="Saving timeline...", value=1, {
      sheet() %>% 
        gs_ws_new(ws_title = filename, input = tv_save, trim = TRUE, verbose = FALSE)
    })
    
    showModal(
      modalDialog(
        title = tagList(icon("thumbs-up"), "Timeline Saved!"),
        paste0("Your timeline has been successfully saved into a worksheet called '", filename, "'"),
        footer=modalButton("Close"),
        easyClose=TRUE
      )
    )
  })
  
  output$calendar_viz <- renderCalheatmap({
    quantmod::getSymbols("AAPL")
    xts_to_df <- function(xt){
      data.frame(
        date = format(as.Date(zoo::index(xt)), '%Y-%m-%d'),
        zoo::coredata(xt)
      )
    }
    dat = xts_to_df(AAPL)
    r1 <- calheatmap('date', 'AAPL.Adjusted',
                     itemSelector = "calendar_viz",
                     data = dat, 
                     domain = 'month',
                     subDomain = 'x_day',
                     subDomainTextFormat = "%d",
                     domainGutter = 10,
                     #legend = seq(5, 40, 20),
                     start = '2017-05-01',
                     #minDate = '2016-01-01',
                     #maxDate = '2018-05-01',
                     weekStartOnMonday=FALSE,
                     range=4,
                     cellSize=25,
                     highlight="now",
                     onClick = JS('function(date, nb) {
                                      alert(date);
                                  }'),
                     previousSelector = '#cal_prev',
                     nextSelector = '#cal_next',
                     ItemName = 'events'
    )
    r1
  })
  
  guests <- reactive({
    withProgress(message="loading guests...", value=1, {
      guests <- sheet() %>% gs_read("guests") %>% data.frame
      guests <- guests %>%
        select(name=Name, relationship=Relationship, plus_one=Plus.One., child=Child., likely_to_attend=Likely.to.attend.Y.N.M) %>%
        # mutate(relationship=as.factor(relationship),
        #        likely_to_attend=as.factor(likely_to_attend)) %>%
        replace_na(list(plus_one=0, child=0, likely_to_attend="M"))
      guests
    })
  })
  
  output$guest_rel <- renderUI({
    selectInput("guest_rel_sel", "Include the following guest types:", choices=unique(guests()$relationship), multiple=TRUE)
  })
  
  output$guest_likely <- renderUI({
    selectInput("guest_likely_sel", "Include the following attendance likelihoods:", choices=unique(guests()$likely_to_attend), multiple=TRUE)
  })
  
  guest_count <- reactive({
    guests <- nrow(guests())
  })
  
  output$guest_count <- renderValueBox({
    valueBox(guest_count(), subtitle="Guests (Estimated)", icon=icon("users"))
  })
  
  output$guest_tbl <- DT::renderDataTable({
    df <- guests()
    names(df) <- c("Name", "Relationship", "Plus One?", "Is Child?", "Likely To Attend?")
    DT::datatable(df, rownames=FALSE, filter="top", options = list(
      lengthMenu = c(10, 50, 100, 250, 500)
      )
    )
  })
  
})