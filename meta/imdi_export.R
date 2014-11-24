setwd("~niko/Desktop/github/data/izma/meta")

library(dplyr)
library(XML)
library(kulife)

start.time <- Sys.time()
source("./../ELAN2R.R")
end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken
rm(end.time, start.time, time.taken)

kpv.corpus.w <- kpv.corpus %>% filter(grepl("\\b[А-ЯӦа-яӧі-]+\\b", Token))
kpv.corpus.w

kpv.meta

kpv.corpus

source("kpv_meta.R")

kpv.imdi <- kpv.meta %>% select(Session_name, Date, Title, ELAN_file, lat_rec, lon_rec, Project_name, Project_title, Project_ID, Project_Contact_ID, Genre) %>% distinct(Session_name) %>% filter(ELAN_file == TRUE) %>% arrange(Date) %>%
        select(-Date, -ELAN_file, -Title, -Project_title, -lat_rec, -lon_rec, -Project_name)

kpv <- merge(kpv.corpus, kpv.meta)
kpv

plot(kpv.meta$lat_rec, kpv.meta$lon_rec)

kpv.corpus
kpv.meta <- kpv.meta %>% rename(Speaker = Naming_convention)

kpv.sub <- kpv.meta %>%
        select()

kpv <- left_join(kpv.corpus, kpv.meta)

kpv %>% select(Token, Naming_convention, Sex, Dialect)
View(kpv)




# kpv.corpus
# kpv.meta

sessions.database <- select(kpv.meta, Session_name, Github, ELAN_file) %>%
        subset(ELAN_file %in% "TRUE" ) %>%
        distinct(Session_name) %>%
        arrange(Session_name) %>%
        select(Session_name)


sessions.elan <- kpv.corpus %>%
        distinct(Session_name) %>%
        arrange(Session_name) %>%
        select(Session_name)

sessions.database
sessions.elan

diff <- sessions.database$Session_name[!sessions.database$Session_name %in% sessions.elan$Session_name]

diff

#        subset(! Attr_Foreign_researcher %in% "TRUE") %>%
#        select(Actor_ID:Recording_year) %>%
#        mutate(Age = Recording_year - Birthtime_year)

imdi

imdi <- xmlTree()
imdi$addTag("METATRANSCRIPT", close=FALSE)
for (i in 1:nrow(kpv.imdi)) {
        for (j in names(kpv.imdi)) {
                imdi$addTag(j, kpv.imdi[i, j])
        }
}
imdi$closeTag()

cat(saveXML(imdi))


#####


imdi <- xmlTree()
imdi$addTag("METATRANSCRIPT", close=FALSE)
for (i in 1:nrow(session.base)) {
        imdi$addTag("Session", close=FALSE)
        for (j in names(kpv.imdi)) {
                imdi$addTag(j, session.base[i, j])
        }
        imdi$addTag("MDGroup", close=FALSE)
                imdi$addTag("Location", close=FALSE)
                for (j in names(session.loc)) {
                imdi$addTag(j, session.loc[i, j])
        }
        imdi$closeTag() # This closes Location
                imdi$addTag("Project", close=FALSE)
                for (j in names(session.project)) {
                imdi$addTag(j, session.project[i, j])
        }
                imdi$addTag("Contact", close=FALSE)
                        for (j in names(session.contact)) {
                        imdi$addTag(j, session.contact[i, j])
        }
        imdi$closeTag() # This closes Contact
        imdi$closeTag() # This closes Project
        imdi$addTag("Keys", close=TRUE)      
        imdi$addTag("Content")
        imdi$closeTag() # This closes MDGroup
        imdi$addTag("Resources", close=FALSE)
        imdi$closeTag()
        imdi$addTag("References", close=FALSE)
        imdi$closeTag()
}
imdi$closeTag()

cat(saveXML(imdi))

####


session.data
###### ANOTHER TEST

imdi <- newXMLNode("METATRANSCRIPT")
addAttributes(imdi, Date=Sys.time(), FormatId="IMDI 3.03", Type="SESSION", Version="0", xmlns="http://www.mpi.nl/IMDI/Schema/IMDI", xmlns.xsi="http://www.w3.org/2001/XMLSchema-instance", xsi.schemaLocation="http://www.mpi.nl/IMDI/Schema/IMDI ./IMDI_3.0.xsd")
Session <- newXMLNode("Session", attrs = c(xmlns.fn="http://www.w3.org/2005/xpath-functions"))
# sort the categories
Actors <- newXMLNode("Actors")
actor <- lapply(seq_along(session.data$Value),function(x){newXMLNode("Actors",
                                                                     attrs = c(symbol = as.character(x-1), value = session.data$Naming_convention[x], label = session.data$Label[x]))
})
addChildren(actors,actor)
# sort the symbols
# symbols <- newXMLNode("symbols")
# symbol <- lapply(seq_along(session.data$Value),function(x){dum.sym <- newXMLNode("symbol",
#                                                                        attrs = c(outputUnit="MM",alpha="1",type="fill",name=as.character(x-1)))
#                                                  layer <- newXMLNode("layer", attrs =c(pass="0",class="SimpleFill",locked="0"))
#                                                  prop <- newXMLNode("prop", attrs =c(k="color",v= session.data$v[x]))
#                                                  addChildren(layer, prop)
#                                                  addChildren(dum.sym, layer)
# }) 

# addChildren(symbols, symbol)

# add categories and symbols to session
addChildren(Session, list(categories, symbols))

addChildren(imdi, list(trans, Session))

imdi
###########



library(XML)
library(kulife)

# NOTE TO SELF: I may need a new join tables for session files and languages spoken...

write.xml(actors.imdi, file="sessions2imdi.xml")
write.xml(sessions.imdi, file="actors2imdi.xml")

# NOTE TO SELF: I may need a new join tables for session files and languages spoken...

write.xml(actors.imdi, file="sessions2imdi.xml")
write.xml(sessions.imdi, file="actors2imdi.xml")

xml <- xmlTreeParse(write.xml(test, file="mydata2.xml"))
xml





### THIS IS A TEST WITH SOME AUDIO STUFF

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

