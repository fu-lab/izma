library(ggplot2)
library(dplyr)
source("helper_functions.R")

shinyServer(function(input, output) {
#        output$text1 <- renderText({ 
#                paste("You have selected to display", input$dialect)
                
        output$map <- renderPlot({
                switch(input$dialect, 
                                        "all" = histogram.all,
                                        "Iźva" = histogram.izva,
                                       "Udora" = histogram.udo)
        })
    }
)

