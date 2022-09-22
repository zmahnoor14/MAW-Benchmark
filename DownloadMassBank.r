start.time <- Sys.time()

library(Spectra)
library(MsBackendMsp)
library(rvest)
library(stringr)
library(xml2)

input_dir <- getwd()

if (!(file.exists(paste(input_dir, "/summaryFile.txt", sep = "")))){
    summaryFile <- paste(input_dir, "/summaryFile.txt", sep = "")
    file.create(summaryFile, recursive = TRUE)
}else{
    summaryFile <- paste(input_dir, "/summaryFile.txt", sep = "")
}
file.conn <- file(summaryFile)
open(file.conn, open = "at")

#print("MassBank WORKS")

page <- read_html("https://github.com/MassBank/MassBank-data/releases")
page %>%
    html_nodes("a") %>%       # find all links
    html_attr("href") %>%     # get the url
    str_subset("MassBank_NIST.msp") -> tmp # find those that have the name MassBank_NIST.msp

#download file
system(paste("wget ",
             "https://github.com", tmp[1],
             sep =  ""))

mbank <- Spectra(paste(input_dir, "/MassBank_NIST.msp", sep = ''), source = MsBackendMsp())
save(mbank, file = paste(input_dir,"/mbankNIST.rda", sep = ""))

# delete the database in its format to free up space
system(paste("rm", (paste(input_dir, "/MassBank_NIST.msp", sep = '')), sep = " "))

# obtain the month and year for the database release to add to summary
res <- str_match(tmp[1], "download/\\s*(.*?)\\s*/MassBank_NIST")


writeLines(paste("MassBank saved at", Sys.time(), "with release version", res[,2], sep=" "),con=file.conn)

end.time <- Sys.time()

time.taken <- end.time - start.time
print(time.taken)
