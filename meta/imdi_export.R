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
setwd("~niko/Desktop/github/data/izma/meta")

kpv.corpus.w <- kpv.corpus %>% filter(grepl("\\b[А-ЯӦа-яӧі-]+\\b", Token))
kpv.corpus.w

source("kpv_meta.R")

kpv.meta

kpv.corpus
project.contact.session

kpv.imdi <- kpv.meta %>% filter(grepl("kpv_izva.+", Session_name)) %>% select(Session_name, Title, Date, ELAN_file, lat_rec, lon_rec, Project_name, Project_title, Project_ID, Project_Contact_ID, Genre) %>% distinct(Session_name) %>% filter(ELAN_file == TRUE) %>% arrange(Date)

        
kpv.imdi

#####

kpv.imdi <- kpv.imdi[1,]
project.contact <- project.contact.session[1,]
project.contact
kpv.imdi


METATRANSCRIPT <- newXMLNode("METATRANSCRIPT")
                                addAttributes(METATRANSCRIPT, Date="test")
Session        <- newXMLNode("Session")
                                addAttributes(Session, xmlns.fn="http://www.w3.org/2005/xpath-functions")
Session_name   <- lapply(seq_along(kpv.imdi$Session_name),function(x){
                                newXMLNode("Name", .children = kpv.imdi$Session_name[x])})
Session_title   <- lapply(seq_along(kpv.imdi$Title),function(x){
                                newXMLNode("Title", .children = kpv.imdi$Title[x])})
Session_title   <- lapply(seq_along(kpv.imdi$Date),function(x){
                                newXMLNode("Date", .children = kpv.imdi$Date[x])})
# Location   <- lapply(seq_along(kpv.imdi$Date),function(x){
#                                newXMLNode("Date", .children = kpv.imdi$Date[x])})
Project_name   <- lapply(seq_along(kpv.imdi$Project_name),function(x){
                                newXMLNode("Project_name", .children = kpv.imdi$Project_name[x])})
Project_title <- lapply(seq_along(kpv.imdi$Project_title),function(x){
                                newXMLNode("Project_title", .children = kpv.imdi$Project_title[x])})
Project_ID <- lapply(seq_along(kpv.imdi$Project_ID),function(x){
                                newXMLNode("Project_ID", .children = kpv.imdi$Project_ID[x])})
Contact_name <- lapply(seq_along(project.contact$Actor_fullname),function(x){
                                newXMLNode("Name", .children = project.contact$Actor_fullname[x])})
Address <- lapply(seq_along(project.contact$Address),function(x){
                                newXMLNode("Address", .children = project.contact$Address[x])})
Email <- lapply(seq_along(project.contact$Email),function(x){
                                newXMLNode("Email", .children = project.contact$Email[x])})
Organisation <- lapply(seq_along(project.contact$Organisation),function(x){
                               newXMLNode("Organisation", .children = project.contact$Organisation[x])})
Genre <- lapply(seq_along(kpv.imdi$Genre),function(x){
                                newXMLNode("Genre", .children = kpv.imdi$Genre[x])})

addChildren(METATRANSCRIPT, Session, Session_name, Session_title, Project_name, Project_title, Project_ID, Contact_name, Address, Email, Organisation, Genre)

kpv.imdi

?addChildren











#######


dfToXML <- function(wavs) {
        session <- newXMLNode("session")
        addAttributes(session, name=wavs$session.name)
        file <- lapply(seq_along(wavs$sample.rate),function(x)
        {newXMLNode("file", .children = wavs$file.name.ext[x])}
        )
        sample.rate <- lapply(seq_along(wavs$sample.rate),function(x)
        {newXMLNode("sample_rate", .children = wavs$sample.rate[x])}
        )
        channels <- lapply(seq_along(wavs$sample.rate),function(x)
        {newXMLNode("channels", .children = wavs$channels[x])}
        )
        bits <- lapply(seq_along(wavs$sample.rate),function(x)
        {newXMLNode("bits", .children = wavs$bits[x])}
        )
        samples <- lapply(seq_along(wavs$sample.rate),function(x)
        {newXMLNode("samples", .children = wavs$samples[x])}
        )
        length <- lapply(seq_along(wavs$sample.rate),function(x)
        {newXMLNode("length", attrs = c(format="seconds"), .children = wavs$length[x])}
        )
        
        addChildren(session, file, sample.rate, channels, bits, samples, length)
        saveXML(session, file=paste0(wavs$path[1], wavs$file.name[1], ".xml"))
}

lapply(wavs, dfToXML)











########
imdi <- xmlTree()
imdi$addTag("METATRANSCRIPT", close=FALSE)
for (i in 1:nrow(kpv.imdi)) {
        imdi$addTag("Session", close=FALSE)
        for (j in names(kpv.imdi)) {
                imdi$addTag(j, kpv.imdi[i, j])
        }
        imdi$addTag("MDGroup", close=FALSE)
                imdi$addTag("Location", close=FALSE)
                for (j in names(kpv.imdi)) {
                imdi$addTag(j, kpv.imdi[i, j])
        }
        imdi$closeTag() # This closes Location
                imdi$addTag("Project", close=FALSE)
                for (j in names(kpv.imdi)) {
                imdi$addTag(j, kpv.imdi[i, j])
        }
                imdi$addTag("Contact", close=FALSE)
                        for (j in names(kpv.imdi)) {
                        imdi$addTag(j, kpv.imdi[i, j])
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

