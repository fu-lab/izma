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

# Errors:

# Error: XML content does not seem to be XML: '...'
# Solution: Check your working directory!

# Error: Error in rbind(deparse.level, ...) : numbers of columns of arguments do not match
# Solution: Usually some XML files have wrong attributes! Check the linguistic types!

# Error: Error: data is not a data frame
# Solution: Check the XML attributes = linguistic types!

# Error: Number of rows doesn't match
# Solution: Some tier is missing the PARTICIPANT attribute!

# At first we define the files we are going to use. Now we exclude folder kpv_novyje.
# If you get errors later in the code this is usually a good place to do changes.
# Try to grep only one file you know is structurally perfect. Once that works, then
# start to take in a larger number of files. It is often that a file or two contain
# some structural mistakes. Try to find those by limiting the content of xmlfiles-object.

# n and dat are objects we use while we parse the XML files. They can be done now as well.
# n shows practically the number of files in xmlfiles object. dat is an empty storage for
# the data that is being read in.

xmlfiles_all <- list.files(path=".", pattern="*.eaf$", recursive=TRUE, full.names=TRUE)
xmlfiles <- xmlfiles_all[ !grepl("kpv_novyje", xmlfiles_all)]
xmlfiles <- xmlfiles[! grepl("meta", xmlfiles)]

xmlfiles_closed <- list.files(path="../closed", pattern="*.eaf$", recursive=TRUE, full.names=TRUE)
xmlfiles_closed <- xmlfiles_closed[ !grepl("kpv_novyje|kpv_kolva", xmlfiles_closed)]

xmlfiles <- c(xmlfiles, xmlfiles_closed)

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
kpv.corpus.wordT

# This checks how many actual word forms there are:
# kpv.corpus.wordT %>% filter(grepl("\\b[А-ЯӦа-яӧі-]+\\b", Token))

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
kpv.corpus.orthT

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
kpv.corpus.refT

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
kpv.corpus.TS

# Then we merge all these together down to the token level. I know the structure
# may feel heavy and redundant, as the same pieces of information are repeated
# again and again. However, the attempt is to format data so that each observation
# is located on its own row. In this case, as usually is in linguistic research,
# we can think each token as its own observation. Naturally other types of arrangement
# are possible as well.

kpv.corpus.wordT
kpv.corpus.orthT
kpv.corpus.refT

kpv.corpus <- left_join(kpv.corpus.wordT, kpv.corpus.orthT)
kpv.corpus <- left_join(kpv.corpus, kpv.corpus.refT)

kpv.corpus <- kpv.corpus %>% 
        left_join(kpv.corpus.TS) %>% 
        rename(Time_start = Time)

glimpse(kpv.corpus)

kpv.corpus <- kpv.corpus %>% 
        select(-TS1) %>% 
        rename(TS1 = TS2) %>% 
        left_join(kpv.corpus.TS) %>% 
        rename(Time_end = Time)

kpv.corpus$Time_start <- as.numeric(as.character(kpv.corpus$Time_start))
kpv.corpus$Time_end <- as.numeric(as.character(kpv.corpus$Time_end))

kpv.corpus <- kpv.corpus %>%
        select(-TS1, -RefID, -OrthID, -TokenID, -Ref)


kpv.corpus$Session_name <- kpv.corpus$Filename
kpv.corpus$Session_name <- gsub(".+/(.+)\\.eaf$", "\\1", kpv.corpus$Session_name, perl = TRUE)

# kpv.corpus %>% distinct(Session_name) %>% select(Session_name)

# kpv.corpus %>% distinct(Session_name) %>% select(Session_name) %>% arrange()

# Let's also remove all empty tokens, as those seem to be present quite a bit.
# They are most likely artefacts of the files that have been segmented further than they've
# been annotated.

kpv.corpus <- kpv.corpus %>% filter(! grepl("^$", Token))

# Let's also create an object that contains word forms as they were, as differentiated
# from word tokens which I'll now take into lowercase.

kpv.corpus$Word <- kpv.corpus$Token
kpv.corpus$Token <- tolower(kpv.corpus$Token)

# This creates digrams and trigrams to kpv.corpus

Token1 <- as.character(kpv.corpus$Token)
Token2 <- Token1[1:length(Token1)+1]
Token3 <- Token2[1:length(Token1)+1]
Token4 <- Token3[1:length(Token1)+1]
Token5 <- Token4[1:length(Token1)+1]
Token6 <- Token5[1:length(Token1)+1]
Token7 <- Token6[1:length(Token1)+1]
Token8 <- Token7[1:length(Token1)+1]

kpv.corpus$Digram <- paste(Token1, Token2)
kpv.corpus$Trigram <- paste(Token1, Token2, Token3)
kpv.corpus$ngram <- paste(Token1, Token2, Token3, Token4, Token5, Token6, Token7, Token8)
kpv.corpus$After <- paste(Token2, Token3, Token4, Token5, Token6)


Token1 <- as.character(kpv.corpus$Token)
Token2 <- Token1[0:(length(Token1)-1)]
Token2 <- append(Token2, "", 0)
Token3 <- Token2[0:(length(Token2)-1)]
Token3 <- append(Token3, "", 0)
Token4 <- Token3[0:(length(Token3)-1)]
Token4 <- append(Token4, "", 0)
Token5 <- Token4[0:(length(Token4)-1)]
Token5 <- append(Token5, "", 0)
Token6 <- Token5[0:(length(Token5)-1)]
Token6 <- append(Token6, "", 0)
Token7 <- Token6[0:(length(Token6)-1)]
Token7 <- append(Token7, "", 0)
Token8 <- Token7[0:(length(Token7)-1)]
Token8 <- append(Token8, "", 0)

kpv.corpus$Before <- paste(Token8, Token7, Token6, Token5, Token4, Token3, Token2)


# This creates a dialect classification based upon filenames - a bit rough way, but works.

kpv.corpus$Dialect <- gsub(".+(kpv_.+)\\d{8}.+$", "\\1", kpv.corpus$Filename, perl = TRUE)

# I try to create also a column that contains the number of words per
# segment on orthography tier

library(stringr)

kpv.corpus$Orth_count <- str_count(kpv.corpus$Orth, pattern = "\\S+")
kpv.corpus$Ref_length <- as.numeric(as.character(kpv.corpus$Time_end)) - as.numeric(as.character(kpv.corpus$Time_start))

        
# kpv.corpus$Orth_count <- str_count(kpv.corpus$Orth, pattern = ".")

# head(kpv.corpus$Orth_count)

kpv.wordcount <- kpv.corpus %>% count(Token) %>% arrange(desc(n))
kpv.corpus <- left_join(kpv.corpus, kpv.wordcount)
kpv.corpus <- kpv.corpus %>% rename(Wordcount = n)

kpv.speakercount <- kpv.corpus %>% count(Session_name) %>% arrange(desc(n))
kpv.corpus <- left_join(kpv.corpus, kpv.speakercount)
kpv.corpus <- kpv.corpus %>% rename(Speakercount = n)

#

#kpv.corpus$Time_start <- as.numeric(kpv.corpus$Time_start)
#kpv.corpus$Time_end <- as.numeric(kpv.corpus$Time_end)

# Let's also create an order column which is necessary because the Time_start is not now word-independent.

kpv.corpus$Order <- 1:nrow(kpv.corpus)

# Let's also turn the timeslots into actual minutes and seconds

kpv.corpus$Time_start_hms <- format(as.POSIXct(Sys.Date())+kpv.corpus$Time_start/1000, "%M:%S")
kpv.corpus$Time_end_hms <- format(as.POSIXct(Sys.Date())+kpv.corpus$Time_end/1000, "%M:%S")

# In the end we remove from workspace the items we used to compose the actual corpus.
# This is of course not necessary, but leads to a nicer workspace.

rm(dat, doc, i, n, nodes, x, xmlfiles_all, xmlfiles_closed)
rm(kpv.corpus.orthT, kpv.corpus.refT, kpv.corpus.TS, kpv.corpus.wordT, Token1, Token2, Token3, Token4, Token5, Token6, Token7, Token8, xmlfiles, kpv.wordcount, kpv.speakercount)

# save(kpv.corpus, file = "/Users/niko/apps/corpus-app/data/kpv.corpus.rda")
######
