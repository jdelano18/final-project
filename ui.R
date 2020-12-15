library(shiny)
library(shinythemes)
library(plotly)
library(DT)
library(tidyverse)
library(shinydashboard)

varChoices = list(
  `Rounds Played` = "Rounds",
  "Wins" = "Wins",
  `Number of Top 10 Finishes` = "Top.10",
  `Winnings (millions of $)` = "Money",
  `Final Official World Golf Ranking` = "Final.OWGR",
  `Average Official World Golf Ranking` = "Average.OWGR",
  `FedEx Cup Points` = "Points",
  `Average Driving Distance (yards)` = "Average.Driving.Distance",
  `Percentage of Fairways Hit` = "Fairway.Percentage",
  `Percentage of Greens in Regulation Hit` = "GIR",
  `Average Number of Putts` = "Average.Putts",
  `Average Scrambling Percentage` = "Average.Scrambling",
  `Average Score` = "Average.Score",
  `Average Strokes Gained: Total` = "Average.SG.Total",
  `Average Strokes Gained: Off the Tee` = "SG.OTT",
  `Average Strokes Gained: Approach` = "SG.APR",
  `Average Strokes Gained: Around the Green` = "SG.ARG",
  `Average Strokes Gained: Putting` = "Average.SG.Putts"
)
masters <- read_csv("data/CT_Masters_playerscores_1934-2020.csv")

# Define UI for application
shinyUI(
  navbarPage(
    "PGA Tour Data Visualization Project",
    theme = shinytheme("simplex"),
    
    tabPanel("About", headerPanel("Add info about project later")),
    
    tabPanel("Season Statistics",
      pageWithSidebar(
        headerPanel(""),
        
        sidebarPanel(
          selectInput("year", label = "Select a year:", choices = seq(2018,2010), selected = 2018),
          selectInput("xcol", label = "Select a variable for the x-axis:", choices = varChoices, selected = "Average.Score"),
          selectInput("ycol", label = "Select a variable for the y-axis:", choices = varChoices, selected = "Money"),
          helpText("Filter golfers based on their final Official World Golf Ranking (OWGR) for the selected season."),
          sliderInput("selectRank", label = "Final Official World Golf Ranking", min = 0, max = 300, value = c(0, 300))
        ),
        
        mainPanel(plotlyOutput("plot1"))
      )
    ),
    
    # tabPanel("Masters", 
    #          # titlePanel("Yearly Tournament Leaderboard"), 
    #          pageWithSidebar(
    #            headerPanel(""),
    #            sidebarPanel(
    #              selectInput(inputId = 'lb_yearly_year',
    #                          label = "Select Year for Tournament Leaderboard:",
    #                          choices = sort(unique(masters$Year), decreasing = T), 
    #                          selected = 2020),
    #              DTOutput("table"),
    #              width = 6),
    #            mainPanel()
    #            )),
    
    tabPanel("Masters", 
             fluidRow(
               column(6, wellPanel(fluidRow(column(12, h3("Yearly Tournament Leaderboard")),
                                                   column(4, selectInput(inputId = 'tourney_year',
                                                                         label = NULL,
                                                                         choices = sort(unique(masters$Year), decreasing = T), 
                                                                         selected = 2020)
                                                          )
                                                   ),
                                          DTOutput("table"))), 
             column(6, wellPanel(fluidRow(column(12, h3("Player Career Statistics")),
                                          #column(4, p("Select a player:"), align = 'right'),
                                          column(6, selectInput(inputId = "player",
                                                                label = NULL,
                                                                choices = sort(unique(masters$Player_FullName)),
                                                                selected = "Tiger Woods"))),
                                 fluidRow(valueBoxOutput(width = 3, "ntourneys"), 
                                          valueBoxOutput(width = 3, "nrounds"),
                                          valueBoxOutput(width = 3, "ncuts"),
                                          valueBoxOutput(width = 3, "lowround")),
                                 fluidRow(valueBoxOutput(width = 3, "wins"), 
                                          valueBoxOutput(width = 3, "runnerup"),
                                          valueBoxOutput(width = 3, "top10"),
                                          valueBoxOutput(width = 3, "top25")),
                                 DTOutput("table2")
                                 )
                    )
             )
)
)
)
