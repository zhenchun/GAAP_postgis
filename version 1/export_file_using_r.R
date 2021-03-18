require(RPostgreSQL)
library(tidyverse)
library(stringr)

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


d1<-as.data.frame(d[,1])
colnames(d1)<-"id"

for (i in 1:length(sites)){
  
  
  
  data<-dbGetQuery(con, paste("SELECT * from ", sites[i], sep=""))
  
  d1<-merge(d1, data, by="id")
  
  colnames(d1)[i+1]<-sites[i]
  
  
  
}


str_sub(colnames(d1)[2:273], 7)


