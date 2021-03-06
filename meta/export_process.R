#Export.csv has been exported from FileMaker Pro from Sessions-view with search Session name=*izva* and Github=T
setwd("~/Desktop/github/data/izma/meta")
library(plyr)
eaf.meta <- read.csv("export.csv", header=F)
eaf.meta <- rename(eaf.meta, c("V1" = "файл", "V2" = "год", "V3" = "сегментаций", "V4" = "расшифровка", "V5" = "русский", "V6" = "английский", "V7" = "спеллер", "V8" = "просмотр", "V9" = "видео?"))
library(dplyr)
eaf.meta <- eaf.meta %>%
        arrange(файл)
write.csv(eaf.meta, file="metadannye_izva.csv")
