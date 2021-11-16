library(RPostgreSQL)
library(tidyverse)
library(stringr)
library(dplyr)
library(RPostgres)



con <- dbConnect(RPostgres::Postgres()
                 , host='localhost'
                 , port='5433'
                 , dbname='postgres'
                 , user='postgres'
                 , password="123")


setwd("C:/Users/zy125/Box/Postdoc/GAAP/GIS")

dbListTables(con)


a1<-dbGetQuery(con, "SELECT * from address_m_to_emi")
a2<-reshape(a1, idvar = "code", timevar = "id", direction = "wide")
a3<-a2[order(a2$code),]
colnames(a3)<-sub("distance.", "", colnames(a3))