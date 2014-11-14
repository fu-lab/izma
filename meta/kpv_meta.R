# This is one way to do this. However, I think it is better to read data directly from the
# database. This is possible by using JCDB connection.

# library(plyr)
# kpv_corpus_meta <- read.csv("./../../kpv_corpus_meta.csv", header=F)
# kpv_corpus_meta <- rename(kpv_corpus_meta, c("V1" = "Speaker", "V2" = "Sex", "V3" = "Birthyear", "V4" = "lat", "V5" = "lon", "V6" = "attr.foreign", "V7" = "Rec.year"))
# kpv_corpus_meta <- unique(kpv_corpus_meta)
# kpv_corpus_meta <- tbl_dt(kpv_corpus_meta)

# So the idea is to create a database connection. First we need library RJDBC.

library(RJDBC)

drv <- JDBC("com.filemaker.jdbc.Driver", "/Library/Java/Extensions/fmjdbc.jar", "‘")

# Then we connect to my Filemaker Pro database "permic_varieties"
# Notice that the database must be open in Filemaker Pro
# You have to set up the rights in File -> Sharing -> Enable ODBC/JDBC

pv <- dbConnect(drv, "jdbc:filemaker://localhost:2399/permic_varieties?user=Admin")

# Instead of doing fancy stuff with SQL we simply read ALL of the tables into R
# and use dplyr for data wrangling purposes. I don't know if this is inelegant or
# otherwise primitive approach, but it is very easy and works! I probably have to learn
# SQL in some point anyway, but for now I think dplyr makes data exploring very much fun.
# I think with an actual MySQL (or similar) database it would be possible to connect even more
# directly to the databases, but for now this is cool enough.
#
# Please notice that I wrap the data frames into local data tables with tbl_df function from dplyr

library(dplyr)

actors <- tbl_df(dbGetQuery(pv, "SELECT  * FROM actors"))
sessions <- tbl_df(dbGetQuery(pv, "SELECT  * FROM sessions"))
actor.links <- tbl_df(dbGetQuery(pv, "SELECT  * FROM actor_links"))
OSM_POR <- tbl_df(dbGetQuery(pv, "SELECT * FROM OSM_ID_POR"))

# Next we join the tables, the last one doesn't join for some reason...

kpv.meta <- left_join(actor.links, actors)
kpv.meta <- left_join(kpv.meta, sessions)
# kpv_meta <- left_join(kpv_meta, OSM_POR, by = c("PlaceofRes_OSM_ID" = "OSM_ID"))

kpv.meta$Dialect <- kpv.meta$Session_name

kpv.meta <- kpv.meta[,order(names(kpv.meta))]

kpv.meta$Dialect <- gsub("kpv_udo.+", "Udora Dialect", kpv.meta$Dialect, perl = TRUE)
kpv.meta$Dialect <- gsub("kpv_izva.+", "Iźva Dialect", kpv.meta$Dialect, perl = TRUE)
kpv.meta$Dialect <- gsub("kpv_skar.+", "Standard Komi", kpv.meta$Dialect, perl = TRUE)
kpv.meta$Dialect <- gsub("kpv_lit.+", "Standard Komi", kpv.meta$Dialect, perl = TRUE)
kpv.meta$Dialect <- gsub("kpv_lit.+", "Vym Dialect", kpv.meta$Dialect, perl = TRUE)
kpv.meta$Dialect <- gsub("kpv_vym.+", "Vym Dialect", kpv.meta$Dialect, perl = TRUE)

# Now we can pick which elements we like and work with them onward. I select the files that are in Github.
# Then I throw away the foreign researchers as we are not so interested about ourselves.
# Please see that we can't merge this object with the transcription data from ELAN files before we have
# made sure that each speaker has a name abbreviation which matches with the participant attribute in ELAN XML.


actors.sessions <-   select(kpv.meta, Actor_ID, Session_name, Naming_convention, Sex, ActorRole, Birthtime_year, Recording_year, Dialect, Github, ELAN_file, Attr_Foreign_researcher) %>%
                subset(Github %in% "TRUE" ) %>%
                subset(! Attr_Foreign_researcher %in% "TRUE") %>%
                select(Actor_ID:Dialect) %>%
                mutate(Age = Recording_year - Birthtime_year) %>%
                arrange(Age)

actor.data <- select(kpv.meta, Actor_ID, Sex, Birthtime_year, Recording_year, Dialect, Github, ELAN_file, Attr_Foreign_researcher) %>%
        subset(Github %in% "TRUE" ) %>%
        subset(! Attr_Foreign_researcher %in% "TRUE") %>%
        select(Actor_ID:Dialect) %>%
        mutate(Age = Recording_year - Birthtime_year) %>%
        distinct(Actor_ID) %>%
        arrange(Age) %>%
        mutate(Age_group = Age)

actor.data$Age_group <- gsub("^[\\d]$|^10$", "1-10", actor.data$Age_group, perl=TRUE)
actor.data$Age_group <- gsub("^(1)(\\d)$|^20$", "10-20", actor.data$Age_group, perl=TRUE)
actor.data$Age_group <- gsub("^(2)(\\d)$|^30$", "20-30", actor.data$Age_group, perl=TRUE)
actor.data$Age_group <- gsub("^(3)(\\d)$|^40$", "30-40", actor.data$Age_group, perl=TRUE)
actor.data$Age_group <- gsub("^(4)(\\d)$|^50$", "40-50", actor.data$Age_group, perl=TRUE)
actor.data$Age_group <- gsub("^(5)(\\d)$|^60$", "50-60", actor.data$Age_group, perl=TRUE)
actor.data$Age_group <- gsub("^(6)(\\d)$|^70$", "60-70", actor.data$Age_group, perl=TRUE)
actor.data$Age_group <- gsub("^(7)(\\d)$|^80$", "70-80", actor.data$Age_group, perl=TRUE)
actor.data$Age_group <- gsub("^(8)(\\d)$|^90$", "80-90", actor.data$Age_group, perl=TRUE)
actor.data$Age_group <- gsub("^(9)(\\d)$|^100$", "90-100", actor.data$Age_group, perl=TRUE)

actor.data
library(ggplot2)
ggplot(actor.data, aes(x=Age_group, fill=Dialect)) + geom_histogram()

# This is an attempt to reformat data into more simple structure. It worked,
# finally, but I also understood that ggplot2 likes data in the long format, in
# which it originally was in.

# actor.data.app <- 
#         actor.data %>%
#         group_by(Age_group, Dialect) %>%
#         tally(sort = TRUE)
# 
# actor.data.izva <- filter(actor.data.app, Dialect=="Iźva Dialect")
# actor.data.udora <- filter(actor.data.app, Dialect=="Udora Dialect")
# actor.data.app <- merge(actor.data.izva, actor.data.udora, by="Age_group")
# actor.data.app <- actor.data.app %>% 
#         select(Age_group, n.x, n.y) %>%
#         rename(Iźva_Dialect = n.x)
# 
# actor.data.app <- actor.data.app %>% 
#         select(Age_group, Iźva_Dialect, n.y) %>%
#         rename(Udora_Dialect = n.y) %>%
#         mutate(All = Iźva_Dialect + Udora_Dialect)

actor.data.app

# Check the verb count()
?rename

saveRDS(actor.data, "/Users/niko/Desktop/github/data/izma/izva-stats-app/data/actor_data.rds")

sessions.IMDI <- select(kpv.meta, Actor_ID, Session_name, Naming_convention, Sex, ActorRole, Birthtime_year, Recording_year, Github, ELAN_file, Attr_Foreign_researcher) %>%
                 subset(Github %in% "TRUE" ) %>%
                 subset(! Attr_Foreign_researcher %in% "TRUE") %>%
                 select(Actor_ID:Recording_year) %>%
                 mutate(Age = Recording_year - Birthtime_year) %>%
                 arrange(Age)

# One thing we have done regularly in Freiburg is to export IMDI XML directly
# from FileMaker Pro. Joshua Wilbur has been perfecting this for a long time,
# and it is indeed possible to export with one mouse click perfectly formatted
# IMDI XML from FileMaker and upload that into TLA servers without opening Arbil
# once. How cool is that!

# We're still lacking a fully functional metadata editor, as far as I see it.
# I use FileMaker myself, but I can't really recommend it to most of my buddies
# as it is still pretty expensive and uses a proprietary format. Thereby someone
# who uses FileMaker has to be tech savvy enough to make sure the data doesn't stay
# in FileMaker. That said, I think it is a very good tool for entering new data.

# However, in essence what it does is to store data into tables. There is just 
# little relational database magic there at the background with unique ID's and 
# stuff like that which keeps it really together and protects the integrity of 
# your data. It's not that we would need all fanciness of the most advanced 
# databases for our data. But to have a relational data model at the background
# does give a great help.

# Despite this it is perfectly possible to mimic the way the data is stored in a
# database in a spreadsheet program. This is actually what I've suggested to my 
# friends. If you make sure that you give each actor and session a unique ID, it
# is very easy to import this later into a database and then into IMDI.

# But I was thinking that as I tell people to use spreadsheet programs as one 
# solution to keep track of their metadata, then I should maybe think some more 
# straightforward way to get that metadata directly into IMDI/CMDI. One way is 
# of course to read the spreadsheets into R, reformat them with dplyr, turn that
# into an XML object, save that, apply an XSLT. Voila. And this same route could
# also be used to export from FileMaker as well, as we now have this nice
# database connection between FileMaker and R.

# Basically the script should send IMDI/CMDI XML into the folders where the rest
# of the session files are stored. At the same time it should actually also copy
# the ELAN files from GitHub into those same folders. There must be a timestamp 
# somewhere indicating the exact export time. The archived versions will 
# certainly be somewhat behind from the files we work with. However, we could
# maybe update them once a week, as an example.

library(XML)
library(kulife)

# NOTE TO SELF: I may need a new join tables for session files and languages spoken...

write.xml(actors.imdi, file="sessions2imdi.xml")
write.xml(sessions.imdi, file="actors2imdi.xml")

xml <- xmlTreeParse(write.xml(test, file="mydata2.xml"))
xml
### This is just a test with FST...

lytkin <- read.csv("/Users/niko/Desktop/github/data/izma/kpv_lit/kpv_lit19570000lytkin.hfst", header = FALSE, sep = "\t")
tbl_df(lytkin)

lytkin <- select()

# In the end you can close the database connection with this command.

dbDisconnect(pv)

############

source("http://www.danielezrajohnson.com/Rbrul.R")
rbrul()

library(audio)
audio.drivers()
audiorec <- function(kk,f){  # kk: time length in seconds; f: filename
        if(f %in% list.files()) 
        {file.remove(f); print('The former file has been replaced');}
        require(audio)
        s11 <- rep(NA_real_, 16000*kk) # rate=16000
        record(s11, 16000, 1)  # record in mono mode
        wait(kk)
        save.wave(s11,f)
}

x <- audioSample(sin(1:8000/10), 8000)
x$rate
x[1:10]
play(x[1:10])

library(audio)
x <- rep(NA_real_, 16000)
# start recording into x
record(x, 18000, 1)
# monitor the recording progress
par(ask=FALSE) # for continuous plotting
while (is.na(x[length(x)])) plot(x, type='l', ylim=c(-1, 1))
# play the recorded audio
play(x)
# save the file
save.wave(x, "x.wav")
