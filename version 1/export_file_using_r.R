require(RPostgreSQL)
library(tidyverse)
library(stringr)
require(dplyr)

con<-dbConnect(dbDriver("PostgreSQL"), dbname="gaap", host="localhost", port=5432, user="postgres", password="123")


setwd("C:/Users/zy125/Box Sync/Postdoc/GAAP/GIS")



#############################site 55 tables

sites<-dbListTables(con)[grepl('^sites', dbListTables(con))]
s<-dbGetQuery(con, "SELECT * from sites_m_to_coast")

s1<-as.data.frame(s[,1])
colnames(s1)<-"id"

for (i in 1:length(sites)){
  
  
  
  data<-dbGetQuery(con, paste("SELECT * from ", sites[i], sep=""))
  
  s1<-merge(s1, data, by="id")
  
  
  
}




#########################################addresses

con<-dbConnect(dbDriver("PostgreSQL"), dbname="gaap", host="localhost", port=5432, user="postgres", password="123")

address<-dbListTables(con)[grepl('^address', dbListTables(con))]

a<-dbGetQuery(con, "SELECT * from address_ll_ferry_route_00050")


a1<-as.data.frame(a[,1])
colnames(a1)<-"id"

for (i in 1:length(address)){
  
  
  
  dat<-dbGetQuery(con, paste("SELECT * from ", address[i], sep=""))
  
  a1<-merge(a1, dat, by="id")
  
  
}

colnames(a1)[1]<-"location_id"


a1<-a1[!grepl('^lu_surface', colnames(a1))] 

load("geocovars_gaap_v9.8.Rdata")



head<-geocovars[1:8]

d1<-merge(head, d1,  by="location_id")

aod<-cbind(geocovars[1], geocovars[grepl('^aod', colnames(geocovars))])

d1<-merge(d1, aod,  by="location_id")




diff<-as.vector(setdiff(colnames(d1), colnames(geo_address)))


diff2<-as.vector(setdiff(colnames(geo_address), colnames(d1)))

d2<-d1[, !(colnames(d1) %in% diff)]


geo_address2<-geo_address[, !(colnames(geo_address) %in% diff2)]


require(arsenal)

summary(comparedf(d2, geo_address2))

