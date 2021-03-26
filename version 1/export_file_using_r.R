require(RPostgreSQL)
library(tidyverse)
library(stringr)
require(dplyr)

con<-dbConnect(dbDriver("PostgreSQL"), dbname="gaap", host="localhost", port=5432, user="postgres", password="123")


setwd("C:/Users/zy125/Box Sync/Postdoc/GAAP/GIS")




for (i in c('5000','3000','1500','1000','750','500','400', '300','200', '150', '100', '50')){
  
 
  
  data<-dbGetQuery(con, paste("SELECT * from ll_road_shxd_", i, sep=""))
  
  write.csv(data, paste("ll_road_shxd_", i, ".csv", sep=""))
  
  
}




data<-dbGetQuery(con, "SELECT * from sites_m_to_suzhou_river")

write.csv(data, paste("m_to_suzhou_river.csv", sep=""))


load("9.6_geocovars_site55.Rdata")


geo_55<-merge(geocovars, ll_suzhou, by="location_id")


geo_55<-merge(geo_55, m_to_suzhou_river, by="location_id")


geocovars<-geo_55
save(geocovars,file="9.7_geocovars_site55.Rdata")








load("geocovars_gaap_v9.6.Rdata")


geocovars<-merge(geocovars, ll_suzhou, by="location_id")


geocovars<-merge(geocovars, m_to_suzhou_river, by="location_id")


save(geocovars,file="geocovars_gaap_v9.7.Rdata")

#############################site 55 tables

sites<-dbListTables(con)[grepl('^sites', dbListTables(con))]
  

  


d<-dbGetQuery(con, "SELECT * from sites_m_to_costal")


for(i in 1: length(sites)){
  
  dbExecute(con, paste("DROP TABLE " ,sites[i]))
  
  }
  

d1<-as.data.frame(d[,1])
colnames(d1)<-"id"

for (i in 1:length(sites)){
  
  
  
  data<-dbGetQuery(con, paste("SELECT * from ", sites[i], sep=""))
  
  d1<-merge(d1, data, by="id")
  
  colnames(d1)[i+1]<-sites[i]
  
  
  
}


str_sub(colnames(d1)[2:273], 7)

#########################################addresses

con<-dbConnect(dbDriver("PostgreSQL"), dbname="gaap", host="localhost", port=5432, user="postgres", password="123")

address<-dbListTables(con)[grepl('^address', dbListTables(con))]

d<-dbGetQuery(con, "SELECT * from address_ll_ferry_00050")


d1<-as.data.frame(d[,1])
colnames(d1)<-"id"

for (i in 1:length(address)){
  
  
  
  data<-dbGetQuery(con, paste("SELECT * from ", address[i], sep=""))
  
  d1<-merge(d1, data, by="id")
  
  
}

colnames(d1)[1]<-"location_id"


d1<-d1[!grepl('^lu_surface', colnames(d1))] 

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

