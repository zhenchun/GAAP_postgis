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





for(i in 1: length(sites)){

dbExecute(con, paste("DROP TABLE " ,sites[i]))

}




for(i in 1: length(address)){
  
  print(dbGetQuery(con, paste("SELECT COUNT(*) FROM " ,address[i])))
  
}





for (i in c('05000','03000','01500','01000','00750','00500','00400', '00300','00200')){
  
  
  
  dbExecute(con, paste("DROP TABLE address_ll_ferry_" ,i, sep=""))
  
  
}
