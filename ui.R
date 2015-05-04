library(shiny)
library(shinydashboard)
library(leaflet)
# Define UI for application that draws a histogram
#shinyUI(fluidPage(
# Application title

dashboardPage(
  
  dashboardHeader(title="SMP"),
  dashboardSidebar(
    textInput("userid","Username",value=""),
    actionButton("goback","Back"),
    actionButton("gonext","Next"),
    actionButton("saveit","Done")),
  dashboardBody(
    #fluidRow(
    #  valueBox("progress",valueBoxOutput("progressBox"),valueBoxOutput("progressBox2")),width=10),
    
    fluidRow(#column(width=4,
      
      ##mapbox
      box(title="Scenario", htmlOutput("inc"),collapsible=T, width=12)),
    
    fluidRow(#column(width=4,
      
      ##mapbox
      box(title="Map",leafletOutput("mapit", height = 300),collapsible=T, width=12)),
    
    
    fluidRow(   
      
      box(title="inputs",
          sliderInput("mean","Most likely value",min = 0,max = 10, step=1,value = 5),
          #htmlOutput("meanslider"), 
          sliderInput("range","Plausible range",min = 0,max = 10, step=1,value = c(0,10)),
          #sliderInput("max","Maximum",min = 0,max = 10, step=1,value = 0),
          sliderInput("beta.l","Left skew",min = 0,max = 20, step=0.1,value = 10,ticks=F),
          sliderInput("beta.r","Right skew",min = 0,max = 20, step=0.1,value = 10,ticks=F)
          
          #)
      ),
      #column(width=8,
      box(title="plot",
          plotOutput("barplot")
      )#)  
    ),
    fluidRow(box(title="results",tableOutput("results")))
  ),)
