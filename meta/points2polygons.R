# Это скрипт читает метаданные, и тоже регионы в формате shapefile. Он взязывает
# информанты с регионом, что у нас будет в метаданны колонна "Dialect".

rm(list = ls())

library(sp)
library(maptools)
library(rgdal)

source("kpv_meta.R")

izva.shp <- readOGR(dsn="./shp",layer="kpv-izma_dial")
kpv.shp <- readOGR(dsn="./shp",layer="kpv_dial")

izva.shp@data
kpv.shp@data

?plot

izva.shp.f <- fortify(izva.shp, outId)
kpv.shp.f <- fortify(kpv.shp, outId)

kpv.shp.f <- merge(kpv.shp.f, kpv.shp@data, by.x = "outId", by.y = "id")


kpv.shp.dial <- rbind.SpatialPolygons(izva.shp, kpv.shp, makeUniqueIDs = TRUE)



kpv.shp.dial@data

plot(kpv.shp.dial)
