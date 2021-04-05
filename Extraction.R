# set the directory the datasets
path = "~/Hackathon2/"
setwd(path)

Lesfichiers <- data.frame(liste_fichiers=list.files())

Compilation <- NULL

for (numfich in 1:2) {
  
  fichier <- as.character(Lesfichiers$liste_fichiers[numfich])
  rangeSheet = c("B6:AN97","B6:AN840")
  
  res <- read_excel(fichier, 1, range = rangeSheet[numfich])
  res <- res[-1,]
  
  Compilation <- rbind(Compilation, res)
}


nameFile <- Lesfichiers[3:6,]
Compilation1 <- NULL

for (numfich in 1:2){
  
  fichier <- as.character(nameFile[numfich])
  rangeSheet = c("B5:AM177","B5:AM1144", "B5:AM105", "B5:AM1272")
  
  res <- read_excel(fichier, 1, range = rangeSheet[numfich])
  res <- res[-1,]
  
  Compilation1 <- rbind(Compilation1, res)
}

Compilation2 <- NULL

for (numfich in 3:4){
  
  fichier <- as.character(nameFile[numfich])
  rangeSheet = c("B5:AM177","B5:AM1144", "B5:AM105", "B5:AM1272")
  
  res <- read_excel(fichier, 1, range = rangeSheet[numfich])
  res <- res[-1,]
  
  Compilation2 <- rbind(Compilation2, res)
}

clean_names <- function(df){
  cn <- colnames(df)
  
  cn_new <- cn %>%
    str_trim() %>%
    tolower() %>% 
    str_replace_all(pattern = "[:blank:]+",replacement = "_") %>%
    str_replace_all(pattern = "[éèê]", replacement = "e") %>%
    str_replace_all(pattern = "[àâ]", replacement = "a") %>%
    str_replace_all(pattern = "[ù]", replacement = "u") %>%
    str_replace_all(pattern = "[î]", replacement = "i") %>%
    str_replace_all(pattern = "[:punct:]+", replacement = '_') 
  
  colnames(df) <- cn_new
  df
}

Compilation <- clean_names(Compilation)
Compilation1 <- clean_names(Compilation1)
Compilation2 <- clean_names(Compilation2)

colnames(Compilation)[6] <- "date_prev"
colnames(Compilation1)[6] <- "date_prev"
colnames(Compilation2)[6]<- "date_prev"

DTRawYear <- rbind(Compilation[, colnames(Compilation1)], Compilation1, Compilation2)

colnames(DTRawYear)[1] <- "n"

rm(list = c('Compilation', 'Compilation1', 'Compilation2'))

write.table(DTRawYear, file = "DTRawYear.txt")
