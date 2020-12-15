library(shiny)
library(shinythemes)
library(plotly)
library(scales)
library(DT)
library(tidyverse)
library(shinydashboard)

varChoices = list(
  "Rounds Played" = "Rounds",
  "Wins" = "Wins",
  "Number of Top 10 Finishes" = "Top.10",
  "Winnings (millions of $)" = "Money",
  "Final Official World Golf Ranking" = "Final.OWGR",
  "Average Official World Golf Ranking" = "Average.OWGR",
  "FedEx Cup Points" = "Points",
  "Average Driving Distance (yards)" = "Average.Driving.Distance",
  "Percentage of Fairways Hit" = "Fairway.Percentage",
  "Percentage of Greens in Regulation Hit" = "GIR",
  "Average Number of Putts" = "Average.Putts",
  "Average Scrambling Percentage" = "Average.Scrambling",
  "Average Score" = "Average.Score",
  "Average Strokes Gained: Total" = "Average.SG.Total",
  "Average Strokes Gained: Off the Tee" = "SG.OTT",
  "Average Strokes Gained: Approach" = "SG.APR",
  "Average Strokes Gained: Around the Green" = "SG.ARG",
  "Average Strokes Gained: Putting" = "Average.SG.Putts"
)

golf <- read_csv("data/finalData.csv")
masters <- read_csv("data/CT_Masters_playerscores_1934-2020.csv")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  # Get min/max fox x-axis and y-axis -- used to fix scales
  xmin <- reactive(golf %>% filter(Year == input$year) %>% select(input$xcol) %>% min())
  xmax <- reactive(golf %>% filter(Year == input$year) %>% select(input$xcol) %>% max())
  ymin <- reactive(golf %>% filter(Year == input$year) %>% select(input$ycol) %>% min())
  ymax <- reactive(golf %>% filter(Year == input$year) %>% select(input$ycol) %>% max())
  
  plotdata <- eventReactive(list(input$xcol, input$ycol, input$selectRank, input$year), {
    golf %>% 
      select(Player, Year, Final.OWGR, input$xcol, input$ycol) %>% 
      filter((Final.OWGR >= input$selectRank[1]) & (Final.OWGR <= input$selectRank[2]) & (Year %in% input$year))
    })
  
  # plot for season statistics
  output$plot1 <- renderPlotly({
    xlab <- names(which(varChoices == input$xcol))
    ylab <- names(which(varChoices == input$ycol))
    
    p <- ggplot(plotdata(), aes_string(x = input$xcol, y = input$ycol, color="Final.OWGR")) +
          geom_point(aes(text = paste0("Player: ", str_to_title(Player), 
                                     "<br>Final OWGR: ", Final.OWGR, 
                                     "<br>", xlab, ": ", round(plotdata()[[input$xcol]], 2),
                                     "<br>", ylab, ": ", round(plotdata()[[input$ycol]], 2), ""))) +
          scale_x_continuous(limits = c(xmin(), xmax()), breaks = pretty_breaks(n = 6)) +
          scale_y_continuous(limits = c(ymin(), ymax()), breaks = pretty_breaks(n = 6)) +
          labs(title = paste0("PGA Tour ", input$year, " Season Plot"),
               x = xlab,
               y = ylab,
               color = "Final OWGR")
     
    ggplotly(p, tooltip="text")
    })
  
  # update year
  tbl_yearly <- reactive(masters %>% filter(Year == as.numeric(input$tourney_year)))
  
  # table for yearly tourneys
  output$table <- renderDT(tbl_yearly() %>% filter(Rds_Complete == 4) %>%
                             # arrange(desc(Rds_Complete), Finish, Total.Score, Last_Name) %>% 
                             arrange(Finish, Last_Name) %>%
                             select(Finish, Player_FullName, R1, R2, R3, R4, Total_Score, Finish_Par) %>%
                             rename("Pos" = "Finish", "Player" = "Player_FullName", "Score" = "Total_Score", "Par" = "Finish_Par"),
                           options = list(info = F,
                                          paging = F,
                                          scrollY='500px',
                                          searching = T),
                           rownames = F)
  
  # get player
  plyr_trns <- reactive({masters %>% 
      filter(Player_FullName == input$player) %>%
      select(Year, R1, R2, R3, R4, Total_Score, Finish_Par, Finish_Group_6, Rds_Complete, Finish) %>%
      rename("Score" = "Total_Score", "Par" = "Finish_Par", "Group" = "Finish_Group_6")
    })
  
  output$table2 <- renderDT(plyr_trns() %>% 
                              select(-Rds_Complete, -Finish) %>% 
                              arrange(desc(Year)), 
                            options = list(info = F,
                                           paging = F,
                                           scrollY='371px',
                                           searching = F),
                            rownames = F)
  
  # render value boxes
  # n tournaments
  output$ntourneys <- renderValueBox({
    val <- nrow(plyr_trns())
    valueBox(value = val, subtitle = "Tournaments")
  })
  # n cuts made
  output$ncuts <- renderValueBox({
    val <- nrow(plyr_trns() %>% filter(!Group %in% c('Missed Cut', 'Withdrew', 'Disqualified')))
    valueBox(value = val, subtitle = "Cuts Made")
  })
  # career low round
  output$lowround <- renderValueBox({
    val <- plyr_trns() %>% 
      select(R1, R2, R3, R4) %>% 
      replace(is.na(.), 99) %>% 
      summarise(val = min(R1, R2, R3, R4)) %>% 
      pull(val)
    valueBox(value = val, subtitle = "Low Round")
  })
  # total n rounds
  output$nrounds <- renderValueBox({
    val <- plyr_trns() %>% summarise(n = sum(Rds_Complete)) %>% pull(n)
    valueBox(value = val, subtitle = "Rounds")
  })
  # green jackets
  output$wins <- renderValueBox({
    val <- nrow(plyr_trns() %>% filter(Group == "Winner"))
    valueBox(value = val, subtitle = "Wins")
  })
  # 2nd place finishes
  output$runnerup <- renderValueBox({
    val <- nrow(plyr_trns() %>% filter(Finish == 2))
    valueBox(value = val, subtitle = "Runner-Ups")
  })
  # top 10s
  output$top10 <- renderValueBox({
    val <- nrow(plyr_trns() %>% filter(Finish <= 10))
    valueBox(value = val, subtitle = "Top 10s")
  })
  # top 25s
  output$top25 <- renderValueBox({
    val <- nrow(plyr_trns() %>% filter(Finish <= 25))
    valueBox(value = val, subtitle = "Top 25s")
  })
  
})
