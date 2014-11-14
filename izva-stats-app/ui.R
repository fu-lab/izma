shinyUI(fluidPage(
        titlePanel("Speakers by Age Groups per Dialect"),
        
        sidebarLayout(position = "right",
                sidebarPanel(
                        selectInput("dialect", label = "Choose Komi variant",
                        choices = list("Iźva",
                                       "Udora",
                                       "all"),
                        selected = "all"),
                        actionButton("feedback", label = "Send Feedback")
                ),
                mainPanel(
                        plotOutput("map"),
                        h4("What is this?"),
                        p("This app has been made in Iźva Komi Documentation project which has been funded by Kone Foundation.
                          It displays the current number of informants in our corpus."),
                        p("There are currently some missing values in our database that display as non available data points. We naturally work hard to minimalize their occurrences, but especially with the heritage data there are always some unknown factors."),  
                        p("It should also be mentioned that there are no histograms for standard Komi or Vym dialect, as there are only individual speakers in the database at the moment.")
                        )
                
        )
))
