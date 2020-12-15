library(tidyverse)

masters <- read_csv("data/CT_Masters_playerscores_1934-2020.csv")
test <- masters %>% filter(Year == 2020) 
test$Pos2 <- as.factor(test$Pos)
test
