library(dplyr)
library(stringr)
library(xlsx) 
library(readxl)

# Load datasets -----------------------------------------------------------

## Set working directory

path = "Hackathon/"
setwd(path)

## Folder list name

listDirname <- list.dirs()

# n_1 <- length(listDirname)

dataRaw <- NULL

for (i in c(2:5, 7:8, 11:14)) {
  
  # i=2
  listFiles <- list.files(path = listDirname[i])
  
  edgeDates <- c("01/01/2014", "31/12/2014")
  
  dfRaw <- NULL
  
  n_2 <- length(listFiles)
  
  for (j in 1:n_2) {
    
    nameFile = paste0(listDirname[i], '/', listFiles[j])
    
    myFile <- read.table(file = nameFile, na.strings = "ABS")
    
    cutInd <- (myFile$V1 %in% edgeDates) %>% which()
    
    if (length(cutInd)==48) {
      
      myFile <- myFile[cutInd[1]:cutInd[48],]
      
    } else{
      
      edgeDates <- c("01/01/2014", "30/12/2014")
      cutInd <- (myFile$V1 %in% edgeDates) %>% which()
      
      myFile <- myFile[cutInd[1]:cutInd[48],]
      
    }
    
    myFile$NameID <- listFiles[j] 
    
    dfRaw <- rbind(dfRaw, myFile)
    
  }
  
  dfRaw$Vague <- str_remove(listDirname[i], "./")
  
  dataRaw <- rbind(dataRaw, dfRaw)

}

colnames(dataRaw)[1:8] <- c("Date", "Heure", paste0("Conso", 1:6))

dataRaw$NameID <- str_remove(dataRaw$NameID, "_Corrigée--cc.txt")
dataRaw$NameID <- str_remove(dataRaw$NameID, "- Export-Compteur-ED2055-In Extenso CARD 101939 -201504231621")
dataRaw$NameID <- str_remove(dataRaw$NameID, ".txt")

# VAGUE 2 - P10CLUTURE dataset (Pay attention) ------------------------------------------------------

listFiles <- list.files(path = listDirname[6])

nameFile = paste0(listDirname[6], '/', listFiles)

P10CULTURE <- read_excel(nameFile, col_names = TRUE)

# VAGUE 2 - JUSTICE_2 ---------------------------------------------------------------

## JUSTICE_2_1

listFiles <- list.files(path = listDirname[9])

nameFile = paste0(listDirname[9], '/', listFiles)

JUSTICE_2_1 <- read_excel(nameFile[1], col_names = FALSE, skip = 1)

colnames(JUSTICE_2_1) <- c("NameID","Date", "Heure", paste0("Conso", 1:6))

JUSTICE_2_1$Vague <- str_remove(listDirname[9], "./")

## JUSTICE_2_2

JUSTICE_2_2 <- NULL

for (i in 2:3) {
  
  myFile <- read.table(nameFile[i])
  JUSTICE_2_2 <- rbind(JUSTICE_2_2, myFile)
  
}

colnames(JUSTICE_2_2) <- c("Date", "Heure", paste0("Conso", 1:6))

JUSTICE_2_2$Vague <- str_remove(listDirname[9], "./")
JUSTICE_2_2$NameID <- str_remove(listFiles[2], ".txt")

# VAGUE 2 - MEDDE -------------------------------------------------------------------

listFiles <- list.files(path = listDirname[10])

nameFile = paste0(listDirname[10], '/', listFiles)

MEDDE_csv <- MEDDE_text <- NULL

len <- length(listFiles)

for (i in 1:len) {
  
  print(paste0("load : ", i))
  
  if(str_detect(nameFile[i], '.csv')){
    
    myFile <- read.table(nameFile[i], sep = ";", na.strings = "ABS")
    
    MEDDE_csv <- rbind(MEDDE_csv, myFile)
    
  }else{
    
    myFile <- read.table(nameFile[i], na.strings = "ABS")
    
    MEDDE_text <- rbind(MEDDE_text, myFile)
    
  }
  print("-------------------")
  
}

out_colnames <- c("V3","V5", "V7", "V9", "V11", "V13")

meddeCsv <-  select(MEDDE_csv, !all_of(out_colnames))

colnames(meddeCsv) <- paste0("V", 1:length(colnames(meddeCsv)))

MEDDE <- rbind(meddeCsv, MEDDE_text)

colnames(MEDDE) <- c("Date", "Heure", paste0("Conso", 1:6))

MEDDE$Vague <- str_remove(listDirname[10], "./")

rm(list = c('meddeCsv', 'MEDDE_text'))
