library(plyr)
kpv_corpus_meta <- read.csv("./../../kpv_corpus_meta.csv", header=F)
kpv_corpus_meta <- rename(kpv_corpus_meta, c("V1" = "Speaker", "V2" = "Sex", "V3" = "Birthyear", "V4" = "lat", "V5" = "lon", "V6" = "attr.foreign", "V7" = "Rec.year"))
kpv_corpus_meta <- unique(kpv_corpus_meta)
