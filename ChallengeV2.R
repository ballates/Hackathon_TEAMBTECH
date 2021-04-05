library(dplyr)
library(stringr)
library(xlsx) 
library(readxl)

# Load datasets -----------------------------------------------------------

## Set working directory

path = "~/Hackathon/"
setwd(path)

## Folder list name

listDirname <- list.dirs()

# Import only the first dataset : writing error

######################################################

ind = 2

listFiles <- list.files(path = listDirname[ind])

dataRaw1 <- dataRaw2 <- dataRaw3 <- NULL

nameFile = paste0(listDirname[ind], '/', listFiles[1])

dataRaw1 <- read.table(file = nameFile, na.strings = "ABS")

dataRaw1$NameID <- listFiles[1] 
dataRaw1$Vague <- str_remove(listDirname[ind], "./")

# Two values didn't well write

dataRaw1$V3 %>% levels()
(dataRaw1$V3== "I274" | dataRaw1$V3== "I317") %>% which()

dataRaw1$V5 %>% levels()
(dataRaw1$V5== "I96") %>% which()

dataRaw1$V3 <- as.integer(dataRaw1$V3)
dataRaw1$V5 <- as.integer(dataRaw1$V5)

for (j in 2:5) {
  
  nameFile = paste0(listDirname[ind], '/', listFiles[j])
  
  myFile <- read.table(file = nameFile, na.strings = "ABS")
  
  myFile$NameID <- listFiles[j] 
  
  dataRaw2 <- rbind(dataRaw2, myFile)
  
}

dataRaw2$Vague <- str_remove(listDirname[ind], "./")

n_1 <- length(listDirname) # folder's number

for (i in c(3:5, 7:8, 11:n_1)) {
  
  listFiles <- list.files(path = listDirname[i])
  
  dfRaw <- NULL
  
  n_2 <- length(listFiles)
  
  for (j in 1:n_2) {
    
    nameFile = paste0(listDirname[i], '/', listFiles[j])
    
    myFile <- read.table(file = nameFile, na.strings = "ABS")
    
    myFile$NameID <- listFiles[j] 
    
    dfRaw <- rbind(dfRaw, myFile)
    
  }
  
  dfRaw$Vague <- str_remove(listDirname[i], "./")
  
  dataRaw3 <- rbind(dataRaw3, dfRaw)
  
}

dataRaw <- rbind(dataRaw1, dataRaw2, dataRaw3)

colnames(dataRaw)[1:8] <- c("date", "heure", paste0("conso", 1:6))

dataRaw$NameID <- str_remove(dataRaw$NameID, "_Corrigée--cc.txt")
dataRaw$NameID <- str_remove(dataRaw$NameID, "- Export-Compteur-ED2055-In Extenso CARD 101939 -201504231621")
dataRaw$NameID <- str_remove(dataRaw$NameID, ".txt")

rm(list = c('dfRaw', 'myFile', "dataRaw1", "dataRaw2", "dataRaw3"))

# VAGUE 2 - P10CLUTURE dataset (Pay attention) ------------------------------------------------------

listFiles <- list.files(path = listDirname[6])

nameFile = paste0(listDirname[6], '/', listFiles)

P10CULTURE <- read_excel(nameFile, col_names = TRUE)

# VAGUE 2 - JUSTICE_2 ---------------------------------------------------------------

## JUSTICE_2_1

listFiles <- list.files(path = listDirname[9])

nameFile = paste0(listDirname[9], '/', listFiles)

JUSTICE_2_1 <- read_excel(nameFile[1], col_names = FALSE, skip = 1)

colnames(JUSTICE_2_1) <- c("NameID","date", "heure", paste0("conso", 1:6))

JUSTICE_2_1$Vague <- str_remove(listDirname[9], "./")

## JUSTICE_2_2

JUSTICE_2_2 <- NULL

for (i in 2:3) {
  
  myFile <- read.table(nameFile[i], na.strings = "ABS")
  JUSTICE_2_2 <- rbind(JUSTICE_2_2, myFile)
  
}

colnames(JUSTICE_2_2) <- c("date", "heure", paste0("conso", 1:6))

JUSTICE_2_2$Vague <- str_remove(listDirname[9], "./")
JUSTICE_2_2$NameID <- str_remove(listFiles[2], ".txt")

JUSTICE <- rbind(JUSTICE_2_1, JUSTICE_2_2)

rm(list = c('JUSTICE_2_1', 'JUSTICE_2_2'))

# VAGUE 2 - MEDDE -------------------------------------------------------------------

listFiles <- list.files(path = listDirname[10])

nameFile = paste0(listDirname[10], '/', listFiles)

MEDDE_csv <- MEDDE_text <- NULL

len <- length(listFiles) # number of files in folder MEDDE

for (i in 1:len) {
  
  print(paste0("load : ", i))
  
  if(str_detect(nameFile[i], '.csv')){
    
    myFile <- read.table(nameFile[i], sep = ";", na.strings = "ABS")
    
    myFile$NameID <- listFiles[j]
    
    MEDDE_csv <- rbind(MEDDE_csv, myFile)
    
  }else{
    
    myFile <- read.table(nameFile[i], na.strings = "ABS")
    
    myFile$NameID <- listFiles[i]
    
    MEDDE_text <- rbind(MEDDE_text, myFile)
    
  }
  print("-------------------")
  
}

out_colnames <- c("V3","V5", "V7", "V9", "V11", "V13")

meddeCsv <-  select(MEDDE_csv, !all_of(out_colnames))

colnames(meddeCsv)[1:8] <- paste0("V", 1:8)

MEDDE <- rbind(meddeCsv, MEDDE_text)

colnames(MEDDE)[1:8] <- c("date", "heure", paste0("conso", 1:6))

MEDDE$Vague <- str_remove(listDirname[10], "./")

rm(list = c('meddeCsv', 'MEDDE_text', 'MEDDE_csv'))

MEDDE[,3:8] <- apply(MEDDE[,3:8], 2, as.integer)

JUSTICE[,4:9] <- apply(JUSTICE[,4:9], 2, as.integer)

dataRaw$date <- as.Date(dataRaw$date, "%d/%m/%Y")
MEDDE$date <- as.Date(MEDDE$date, "%d/%m/%Y")

DTRaw <- rbind(dataRaw, JUSTICE, MEDDE) # Get all Vague of data till 1 to 3

rm(list = c('dataRaw', 'JUSTICE', 'MEDDE', 'myFile'))

write.table(DTRaw, file = "DTRaw.txt")
