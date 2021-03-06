# This loads any csv in any schema
# given a path containing csv.
# structure is infered

#install.packages("remotes")
#remotes::install_github("r-dbi/RPostgres")
args = commandArgs(trailingOnly=TRUE)
library(RPostgres)
library(DBI)

SCHEMA_TARGET <<- args[1] #mimic or mimiciii

getValueFromConfFile <- function(file, pattern){
	gsub(paste0(pattern,"="),"",grep(paste0("^",pattern,"="), scan(file,what="",quiet=T),value=T))
}

connect <- function(){
	connectionFile <- file.path("~/mimic-omop.cfg")
	conn <- RPostgres::dbConnect(RPostgres::Postgres() 
				     ,dbname = getValueFromConfFile(connectionFile,"dbname")
				     ,host = getValueFromConfFile(connectionFile,"host")
				     ,port = getValueFromConfFile(connectionFile,"port")
				     ,user = getValueFromConfFile(connectionFile,"user")
				     ,password = getValueFromConfFile(connectionFile,"password")
				     )
}

con <<- connect()

readDf <- function(path){
read.table(path,sep=",",header=TRUE, quote="\"", fill=TRUE, comment.char = "")
}

tableName <- function(name){
paste0("gcpt_",gsub("\\.csv$","",name))
}

mooveSchema <- function(table, schema){
sql <- sprintf("ALTER TABLE %s SET SCHEMA %s", tableName(table), schema)
dbSendQuery(con, sql)
sql <- sprintf("ALTER TABLE %s.%s add column mimic_id integer default nextval('%s.mimic_id_concept_seq'::regclass);", schema, tableName(table), SCHEMA_TARGET)
dbSendQuery(con, sql)
}

dropTable <- function(table, schema){
sql <- sprintf("DROP TABLE IF EXISTS %s.%s;", schema, tableName(table))
dbSendQuery(con, sql)
}

PATH_CSV <- "~/git/mimic-omop/extras/concept/"
fichs <- list.files(PATH_CSV,pattern="*.csv")
for(fich in fichs){
	tmp <- readDf(file.path(PATH_CSV,fich))
	names(tmp) <- tolower(names(tmp))
	dropTable(fich, SCHEMA_TARGET)
	dbWriteTable(con, tableName(fich), tmp, overwrite=TRUE)
	mooveSchema(fich, SCHEMA_TARGET)
}
