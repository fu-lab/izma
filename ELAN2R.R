# Тайӧ скрипт лыддьӧ ЕЛАН-файлъяс кыв-тиеръясті. Йитча сылӧн дата фрамесӧ менам 
# Филемакер метаданныекӧд.

# This script reads the content of ELAN files that are in folders under it. It
# reads only the tiers with the linguistic type wordT, and it joins this data
# with participant attributes for those tiers + filenames. Now it also takes the
# ANNOTATION_ID's, as those can be used later to merge this structure with data
# coming from FST.

# The script doesn't assume very much about the data, but it requires
# that each word-tier has a participant and that each word-tier has at least one
# annotation. The folder structure is such that the files that do not fill these
# criteria are in the folder kpv_novyje, content of that file is excluded from 
# the object xmlfiles_all.

# I often use this script from another script with 
# commands like "source("./../ELAN2R.R")" This play with the setting of working 
# directory is just one way to keep stuff running, but ideally there would be no
# parameters that are somehow speficied to my computer. The idea is that the
# filenames correspond exactly with the session names. This way it is possible
# to connect participant and session specific metadata with the content of
# word-tiers.

setwd("~niko/Desktop/github/data/izma")

library(XML)
xmlfiles_all <- list.files(path=".", pattern="*.eaf$", recursive=TRUE)
xmlfiles <- xmlfiles_all[ !grepl("kpv_novyje", xmlfiles_all) ]

n <- length(xmlfiles)
dat <- vector("list", n)
for(i in 1:n){
        doc <- xmlTreeParse(xmlfiles[i], useInternalNodes = TRUE)
        nodes <- getNodeSet(doc, "//TIER[@LINGUISTIC_TYPE_REF='wordT']")
        x<- lapply(nodes, function(x){ data.frame(
                Filename = xmlfiles[i],
                Speaker = xpathSApply(x, "." , xmlGetAttr, "PARTICIPANT"),
                Token_ID = xpathSApply(x, ".//ANNOTATION/REF_ANNOTATION" , xmlGetAttr, "ANNOTATION_ID"),
                Word= xpathSApply(x, ".//ANNOTATION/REF_ANNOTATION/ANNOTATION_VALUE" , xmlValue) )})
        dat[[i]] <- do.call("rbind", x)
}

kpv_corpus <- do.call("rbind", dat)

kpv_corpus
setwd("~niko/Desktop/github/data/izma/meta")
