# We read the metadata directly from the
# database. This is possible by using JCDB connection.

# So the idea is to create a database connection. First we need library RJDBC.

library(RJDBC)

drv <- JDBC("com.filemaker.jdbc.Driver", "/Library/Java/Extensions/fmjdbc.jar", "‘")

# Then we connect to my Filemaker Pro database "permic_varieties"
# Notice that the database must be open in Filemaker Pro
# You have to set up the rights in File -> Sharing -> Enable ODBC/JDBC

pv <- dbConnect(drv, "jdbc:filemaker://localhost:2399/permic_varieties?user=Admin")

library(dplyr)

actors <- tbl_df(dbGetQuery(pv, "SELECT  * FROM actors"))

sessions <- tbl_df(dbGetQuery(pv, "SELECT  * FROM sessions"))
actor.links <- tbl_df(dbGetQuery(pv, "SELECT  * FROM actor_links"))

OSM_por <- tbl_df(dbGetQuery(pv, "SELECT * FROM OSM_ID_POR")) %>%
        select(OSM_ID, lat, lon) %>%
        rename(lat_por = lat) %>%
        rename(lon_por = lon)

OSM_rec <- tbl_df(dbGetQuery(pv, "SELECT * FROM OSM_ID_Rec_place")) %>%
        select(OSM_ID, lat, lon) %>%
        rename(lat_rec = lat) %>%
        rename(lon_rec = lon)

OSM_birth <- tbl_df(dbGetQuery(pv, "SELECT * FROM OSM_ID_Birthplace")) %>%
        select(OSM_ID, lat, lon) %>%
        rename(lat_birth = lat) %>%
        rename(lon_birth = lon)

project <- tbl_df(dbGetQuery(pv, "SELECT * FROM fieldwork"))

project$Project_title <- project$Project_name

# Next we join the tables
#OSM <- OSM_rec$OSM_ID
#OSM <- as.data.frame(OSM)
#OSM[duplicated(OSM),]
#filter(OSM_rec, duplicated(OSM_rec))

kpv.meta <- left_join(actor.links, actors)
kpv.meta <- left_join(kpv.meta, sessions)

####

kpv.meta <- kpv.meta %>% filter(ELAN_file == TRUE) %>% select(Naming_convention, Session_name, Birthtime_year, Recording_year, PlaceofRes_OSM_ID, RecPlace_OSM_ID, Birthplace_OSM_ID, Sex, Attr_Foreign_researcher, ELAN_file, Style, Genre, Mode, Aligned, Title)


OSM_rec <- OSM_rec %>% rename(RecPlace_OSM_ID = OSM_ID)
kpv.meta <- left_join(kpv.meta, OSM_rec)

# View(kpv.meta)

OSM_por <- OSM_por %>% rename(PlaceofRes_OSM_ID = OSM_ID)
kpv.meta <- left_join(kpv.meta, OSM_por)

OSM_birth <- OSM_birth %>% rename(Birthplace_OSM_ID = OSM_ID)
kpv.meta$Birthplace_OSM_ID <- as.character(kpv.meta$Birthplace_OSM_ID)
kpv.meta <- left_join(kpv.meta, OSM_birth)
kpv.meta
###

# project

# kpv.meta <- left_join(kpv.meta, project)

#project.contact.session <- kpv.meta %>% select(Session_name, Project_Contact_ID) %>% unique() %>% rename(Actor_ID = Project_Contact_ID)
#project.contact.session <- left_join(project.contact.session, actors) %>% select(Session_name, Actor_ID, Actor_fullname, Address, Email, Organisation)


# kpv.meta %>% filter(Session_name == "kpv_izva20140328-1Varysh") %>% select(Actor_fullname, Session_name, lat_rec, lon_rec)


kpv.meta$Date <- kpv.meta$Session_name
kpv.meta$Date <- gsub(".+(\\d\\d\\d\\d)(\\d\\d)(\\d\\d).+", "\\1-\\2-\\3", kpv.meta$Date, perl = TRUE)

kpv.meta <- kpv.meta %>%  mutate(Age = Recording_year - Birthtime_year)
kpv.meta$Age_group <- kpv.meta$Age

kpv.meta$Age_group <- gsub("^[\\d]$|^10$", "1-10", kpv.meta$Age_group, perl=TRUE)
kpv.meta$Age_group <- gsub("^(1)(\\d)$|^20$", "10-20", kpv.meta$Age_group, perl=TRUE)
kpv.meta$Age_group <- gsub("^(2)(\\d)$|^30$", "20-30", kpv.meta$Age_group, perl=TRUE)
kpv.meta$Age_group <- gsub("^(3)(\\d)$|^40$", "30-40", kpv.meta$Age_group, perl=TRUE)
kpv.meta$Age_group <- gsub("^(4)(\\d)$|^50$", "40-50", kpv.meta$Age_group, perl=TRUE)
kpv.meta$Age_group <- gsub("^(5)(\\d)$|^60$", "50-60", kpv.meta$Age_group, perl=TRUE)
kpv.meta$Age_group <- gsub("^(6)(\\d)$|^70$", "60-70", kpv.meta$Age_group, perl=TRUE)
kpv.meta$Age_group <- gsub("^(7)(\\d)$|^80$", "70-80", kpv.meta$Age_group, perl=TRUE)
kpv.meta$Age_group <- gsub("^(8)(\\d)$|^90$", "80-90", kpv.meta$Age_group, perl=TRUE)
kpv.meta$Age_group <- gsub("^(9)(\\d)$|^100$", "90-100", kpv.meta$Age_group, perl=TRUE)

# kpv.corpus$Birth_dec <- kpv.corpus$Birthyear
#
# kpv.meta$Birth_dec <- gsub("^[\\d]$|^10$", "1-10", kpv.meta$Birth_dec, perl=TRUE)
# kpv.meta$Birth_dec <- gsub("^(1)(\\d)$|^20$", "10-20", kpv.meta$Birth_dec, perl=TRUE)
# kpv.meta$Birth_dec <- gsub("^(2)(\\d)$|^30$", "20-30", kpv.meta$Birth_dec, perl=TRUE)
# kpv.meta$Birth_dec <- gsub("^(3)(\\d)$|^40$", "30-40", kpv.meta$Birth_dec, perl=TRUE)
# kpv.meta$Birth_dec <- gsub("^(4)(\\d)$|^50$", "40-50", kpv.meta$Birth_dec, perl=TRUE)
# kpv.meta$Birth_dec <- gsub("^(5)(\\d)$|^60$", "50-60", kpv.meta$Birth_dec, perl=TRUE)
# kpv.meta$Birth_dec <- gsub("^(6)(\\d)$|^70$", "60-70", kpv.meta$Birth_dec, perl=TRUE)
# kpv.meta$Birth_dec <- gsub("^(7)(\\d)$|^80$", "70-80", kpv.meta$Birth_dec, perl=TRUE)
# kpv.meta$Birth_dec <- gsub("^(8)(\\d)$|^90$", "80-90", kpv.meta$Birth_dec, perl=TRUE)
# kpv.meta$Birth_dec <- gsub("^(9)(\\d)$|^100$", "90-100", kpv.meta$Birth_dec, perl=TRUE)


# Now we can pick which elements we like and work with them onward. I select the files that are in Github.
# Then I throw away the foreign researchers as we are not so interested about ourselves.
# Please see that we can't merge this object with the transcription data from ELAN files before we have
# made sure that each speaker has a name abbreviation which matches with the participant attribute in ELAN XML.

# STUFF ABOVE THIS SHOULD BE CLEANED AND SOURCED IN ITS OWN FILE!!!

# This prepares and sends data to izva-stats-app.

# actor.data <- select(kpv.meta, Actor_ID, Sex, Birthtime_year, Recording_year, Dialect, Github, ELAN_file, Attr_Foreign_researcher) %>%
#         subset(Github %in% "TRUE" ) %>%
# #        subset(! Attr_Foreign_researcher %in% "TRUE") %>%
#         select(Actor_ID:Dialect) %>%
#         mutate(Age = Recording_year - Birthtime_year) %>%
#         distinct(Actor_ID) %>%
#         arrange(Age) %>%
#         mutate(Age_group = Age)
#
# actor.data$Age_group <- gsub("^[\\d]$|^10$", "1-10", actor.data$Age_group, perl=TRUE)
# actor.data$Age_group <- gsub("^(1)(\\d)$|^20$", "10-20", actor.data$Age_group, perl=TRUE)
# actor.data$Age_group <- gsub("^(2)(\\d)$|^30$", "20-30", actor.data$Age_group, perl=TRUE)
# actor.data$Age_group <- gsub("^(3)(\\d)$|^40$", "30-40", actor.data$Age_group, perl=TRUE)
# actor.data$Age_group <- gsub("^(4)(\\d)$|^50$", "40-50", actor.data$Age_group, perl=TRUE)
# actor.data$Age_group <- gsub("^(5)(\\d)$|^60$", "50-60", actor.data$Age_group, perl=TRUE)
# actor.data$Age_group <- gsub("^(6)(\\d)$|^70$", "60-70", actor.data$Age_group, perl=TRUE)
# actor.data$Age_group <- gsub("^(7)(\\d)$|^80$", "70-80", actor.data$Age_group, perl=TRUE)
# actor.data$Age_group <- gsub("^(8)(\\d)$|^90$", "80-90", actor.data$Age_group, perl=TRUE)
# actor.data$Age_group <- gsub("^(9)(\\d)$|^100$", "90-100", actor.data$Age_group, perl=TRUE)
#
# actor.data <- actor.data %>% select(-Age, -Birthtime_year, -Recording_year)

# saveRDS(actor.data, "/Users/niko/Desktop/github/data/izma/izva-stats-app/data/actor_data.rds")

# session.data <- kpv.meta %>%
#         select(Actor_ID, Session_name, Naming_convention, Sex, ActorRole, Birthtime_year, Recording_year, Github, ELAN_file, Attr_Foreign_researcher) %>%
#         subset(ELAN_file %in% "TRUE" ) %>%
#         select(Actor_ID:Recording_year) %>%
#         mutate(Age = Recording_year - Birthtime_year) %>%
#         select(-Actor_ID) %>%
#         arrange(Age)
#
# session.data


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


# Check the verb count()

rm(actors, actor.links, OSM_por, OSM_rec, project, sessions, OSM_birth)

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

# In the end you can close the database connection with this command.

dbDisconnect(pv)
rm(pv, drv)

kpv.meta %>%
        rename(Speaker = Naming_convention) %>%
        rename(Birthtime = Birthtime_year) %>%
        rename(Rectime = Recording_year) %>%
        rename(Attr_foreign = Attr_Foreign_researcher) %>%
        select(-PlaceofRes_OSM_ID, -RecPlace_OSM_ID, -Birthplace_OSM_ID) -> kpv.meta

kpv.meta$lat_rec <- as.numeric(kpv.meta$lat_rec)
kpv.meta$lon_rec <- as.numeric(kpv.meta$lon_rec)
kpv.meta$lat_por <- as.numeric(kpv.meta$lat_por)
kpv.meta$lon_por <- as.numeric(kpv.meta$lon_por)
kpv.meta$lat_birth <- as.numeric(kpv.meta$lat_birth)
kpv.meta$lon_birth <- as.numeric(kpv.meta$lon_birth)

save(kpv.meta, file = "/Users/niko/R/package/FRelan/vignettes//kpv.meta.rda")
meta_kpv <- kpv.meta
rm(kpv.meta)
