---
Readme file for the app -- very unfinished
---

You can open R or RStudio and run following commands. It should run the app. On the third line you need to set the directory for folder **izma**.

Тайӧс позьӧ вӧдитчыны R ливӧ RStudio программаясын. Куймӧдӧ колӧ пуктыны туй тайӧ папкаӧ, кӧні апылӧн файл, ӧні сійӧ папка **izma**.

Можете пробывать это с R или RStudio. Как я пробывал он работал. На третий линии нужен писат путь до папку где апы, сейчас **izma**.

    install.packages("shiny")
    install.packages("ggplot2")
    library(shiny)
    setwd("**PATH**/**ТУЙ**/**ПАПКА**/izma")
    runApp("izma/izva-stats-app")