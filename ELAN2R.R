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

# These packages will be used

library(XML)
library(dplyr)

# At first we define the files we are going to use. Now we exclude folder kpv_novyje.
# If you get errors later in the code this is usually a good place to do changes.
# Try to grep only one file you know is structurally perfect. Once that works, then
# start to take in a larger number of files. It is often that a file or two contain
# some structural mistakes. Try to find those by limiting the content of xmlfiles-object.

# n and dat are objects we use while we parse the XML files. They can be done now as well.
# n shows practically the number of files in xmlfiles object. dat is an empty storage for
# the data that is being read in.

xmlfiles_all <- list.files(path=".", pattern="*.eaf$", recursive=TRUE)
xmlfiles <- xmlfiles_all[ !grepl("kpv_novyje", xmlfiles_all) ]

n <- length(xmlfiles)

dat <- vector("list", n)

# This part of the code reads all content of the word-tiers and saves it to a new object.

for(i in 1:n){
        doc <- xmlTreeParse(xmlfiles[i], useInternalNodes = TRUE)
        nodes <- getNodeSet(doc, "//TIER[@LINGUISTIC_TYPE_REF='wordT']")
        x <- lapply(nodes, function(x){ data.frame(
                Filename = xmlfiles[i],
                Speaker = xpathSApply(x, "." , xmlGetAttr, "PARTICIPANT"),
                TokenID = xpathSApply(x, ".//ANNOTATION/REF_ANNOTATION" , xmlGetAttr, "ANNOTATION_ID"),
                OrthID = xpathSApply(x, ".//ANNOTATION/REF_ANNOTATION" , xmlGetAttr, "ANNOTATION_REF"),
                Token = xpathSApply(x, ".//ANNOTATION/REF_ANNOTATION/ANNOTATION_VALUE" , xmlValue) )})
        dat[[i]] <- do.call("rbind", x)
}

kpv.corpus.wordT <- tbl_df(do.call("rbind", dat))

# After this we read through all orthography tiers. That's where the basic transcription lives.

for(i in 1:n){
        doc <- xmlTreeParse(xmlfiles[i], useInternalNodes = TRUE)
        nodes <- getNodeSet(doc, "//TIER[@LINGUISTIC_TYPE_REF='orthT']")
        x <- lapply(nodes, function(x){ data.frame(
                Filename = xmlfiles[i],
                Speaker = xpathSApply(x, "." , xmlGetAttr, "PARTICIPANT"),
                OrthID = xpathSApply(x, ".//ANNOTATION/REF_ANNOTATION" , xmlGetAttr, "ANNOTATION_ID"),
                RefID = xpathSApply(x, ".//ANNOTATION/REF_ANNOTATION" , xmlGetAttr, "ANNOTATION_REF"),
                Orth = xpathSApply(x, ".//ANNOTATION/REF_ANNOTATION/ANNOTATION_VALUE" , xmlValue) )})
        dat[[i]] <- do.call("rbind", x)
}

kpv.corpus.orthT <- tbl_df(do.call("rbind", dat))

# The same is done also to the reference tiers. They are the highest level tiers in our structure.

for(i in 1:n){
        doc <- xmlTreeParse(xmlfiles[i], useInternalNodes = TRUE)
        nodes <- getNodeSet(doc, "//TIER[@LINGUISTIC_TYPE_REF='ref(spoken)T']")
        x <- lapply(nodes, function(x){ data.frame(
                Filename = xmlfiles[i],
                Speaker = xpathSApply(x, "." , xmlGetAttr, "PARTICIPANT"),
                RefID = xpathSApply(x, ".//ANNOTATION/ALIGNABLE_ANNOTATION" , xmlGetAttr, "ANNOTATION_ID"),
                TS1 = xpathSApply(x, ".//ANNOTATION/ALIGNABLE_ANNOTATION" , xmlGetAttr, "TIME_SLOT_REF1"),
                TS2 = xpathSApply(x, ".//ANNOTATION/ALIGNABLE_ANNOTATION" , xmlGetAttr, "TIME_SLOT_REF2"),
                Ref = xpathSApply(x, ".//ANNOTATION/ALIGNABLE_ANNOTATION/ANNOTATION_VALUE" , xmlValue) )})
        dat[[i]] <- do.call("rbind", x)
}

kpv.corpus.refT <- tbl_df(do.call("rbind", dat))

# Only after we have the reference tiers we can move up to the timeslots.

for(i in 1:n){
        doc <- xmlTreeParse(xmlfiles[i], useInternalNodes = TRUE)
        nodes <- getNodeSet(doc, "//TIME_ORDER")
        x <- lapply(nodes, function(x){ data.frame(
                Filename = xmlfiles[i],
                TS1 = xpathSApply(x, ".//TIME_SLOT" , xmlGetAttr, "TIME_SLOT_ID"),
                Time = xpathSApply(x, ".//TIME_SLOT" , xmlGetAttr, "TIME_VALUE")  )})
        dat[[i]] <- do.call("rbind", x)
}

kpv.corpus.TS <- tbl_df(do.call("rbind", dat))

# Then we merge all these together down to the token level. I know the structure
# may feel heavy and redundant, as the same pieces of information are repeated
# again and again. However, the attempt is to format data so that each observation
# is located on its own row. In this case, as usually is in linguistic research,
# we can think each token as its own observation. Naturally other types of arrangement
# are possible as well.

kpv.corpus.wordT
kpv.corpus.orthT
kpv.corpus.refT
kpv.corpus.TS

kpv.corpus <- left_join(kpv.corpus.wordT, kpv.corpus.orthT)
kpv.corpus <- left_join(kpv.corpus, kpv.corpus.refT)
kpv.corpus <- left_join(kpv.corpus, kpv.corpus.TS)

kpv.corpus <- kpv.corpus %>%
        rename(TS1_old = TS1) %>%
        rename(Time_start = Time)

kpv.corpus <- kpv.corpus %>%
        rename(TS1 = TS2)

kpv.corpus <- left_join(kpv.corpus, kpv.corpus.TS)

kpv.corpus <- kpv.corpus %>%
        rename(TS2_old = TS1) %>%
        rename(Time_end = Time)

kpv.corpus <- kpv.corpus %>%
        select(-TS2_old, -TS1_old, -RefID, -OrthID, -TokenID, -Ref)

kpv.corpus$Session_name <- kpv.corpus$Filename
kpv.corpus$Session_name <- gsub("kpv_izva/", "", kpv.corpus$Session_name, perl = TRUE)
kpv.corpus$Session_name <- gsub("kpv_udora/", "", kpv.corpus$Session_name, perl = TRUE)
kpv.corpus$Session_name <- gsub("kpv_dialektjas/", "", kpv.corpus$Session_name, perl = TRUE)
kpv.corpus$Session_name <- gsub("kpv_lit/", "", kpv.corpus$Session_name, perl = TRUE)
kpv.corpus$Session_name <- gsub("\\.eaf", "", kpv.corpus$Session_name, perl = TRUE)
# kpv.corpus %>% distinct(Session_name) %>% select(Session_name) %>% arrange()

# In the end we remove from workspace the items we used to compose the actual corpus.
# This is of course not necessary, but leads to a nicer workspace.
rm(dat, doc, i, n, nodes, x, xmlfiles, xmlfiles_all)
rm(kpv.corpus.orthT, kpv.corpus.refT, kpv.corpus.TS, kpv.corpus.wordT)
######

setwd("~niko/Desktop/github/data/izma/meta")
