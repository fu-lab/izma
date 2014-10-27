# Тайӧ скрипт лыддьӧ ЕЛАН-файлъяс кыв-тиеръясті. Йитча сылӧн дата фрамесӧ менам Филемакер метаданныекӧд.

setwd("~niko/Desktop/github/data/izma")

library(XML)
xmlfiles_all <- list.files(path=".", pattern="*.eaf$", recursive=TRUE)
xmlfiles <- xmlfiles_all[ !grepl("kpv_novyje",xmlfiles_all) ]
n <- length(xmlfiles)
dat <- vector("list", n)
for(i in 1:n){
        doc <- xmlTreeParse(xmlfiles[i], useInternalNodes = TRUE)
        nodes <- getNodeSet(doc, "//TIER[@LINGUISTIC_TYPE_REF='wordT']")
        x<- lapply(nodes, function(x){ data.frame(
                Filename = xmlfiles[i],
                Speaker= xpathSApply(x, "." , xmlGetAttr, "PARTICIPANT"),
                Word= xpathSApply(x, ".//ANNOTATION/REF_ANNOTATION/ANNOTATION_VALUE" , xmlValue) )})
        dat[[i]] <- do.call("rbind", x)
}
kpv_corpus <- do.call("rbind", dat)

setwd("~niko/Desktop/github/data/izma/meta")