start.time <- Sys.time()

library(Spectra)
#library(MsBackendMgf)
library(MsBackendMsp)

input_dir <- getwd()

system(paste("wget -P", input_dir, "https://gnps-external.ucsd.edu/gnpslibrary/ALL_GNPS.msp", sep =  " "))

if (!(file.exists(paste(input_dir, "/summaryFile.txt", sep = "")))){
    summaryFile <- paste(input_dir, "/summaryFile.txt", sep = "")
    file.create(summaryFile, recursive = TRUE)
}else{
    summaryFile <- paste(input_dir, "/summaryFile.txt", sep = "")
}
file.conn <- file(summaryFile)
open(file.conn, open = "at")

# load the spectra into MsBackendMgf
gnpsdb <- Spectra(paste(input_dir, "/ALL_GNPS.msp", sep = ''), source = MsBackendMsp())

save(gnpsdb, file = paste(input_dir,"/gnps.rda", sep = ""))

# delete the database in its format to free up space
system(paste("rm", (paste(input_dir, "/ALL_GNPS.msp", sep = '')), sep = " "))

writeLines(paste("GNPS saved at", Sys.time(), sep=" "),con=file.conn)

end.time <- Sys.time()

time.taken <- end.time - start.time
print(time.taken)
