start.time <- Sys.time()

# load the functions file
source('/opt/workdir/Workflow_R_Functions.r')

# ---------- Script ----------
# input directory
input_dir <- getwd()
#input_dir <- "/Users/mahnoorzulfiqar/OneDriveUNI/MAW-data/MTBLS709_Data_32"
#input_dir

install.packages(c("parallel", "doParallel", "foreach", "future", "iterators"))

library(parallel)
library(doParallel)
library(foreach)
library(future)
library(iterators)



options(future.globals.maxSize = 8 * 1024^3) # increase dataset size limit taken by future to 8GB

# detects number of cores
n.cores <- parallel::detectCores()

# creates the parallel cluster
my.cluster <- parallel::makeCluster(
  n.cores,
  type = "FORK"
  )

# register it to be used by %dopar%
doParallel::registerDoParallel(cl = my.cluster)

plan(cluster, workers = my.cluster)

input_table <- data.frame(ms2_rfilename(input_dir))

i <- 1

spec_pr <- spec_Processing(input_dir,
                           input_table[i, "mzml_files"], 
                           input_table[i, "ResultFileNames"])


#perform dereplication with all dbs
df_derep <- spec_dereplication_file(mzml_file = input_table[i, "mzml_files"],
                               pre_tbl = paste(input_dir, str_remove(paste(input_table[i, "ResultFileNames"], "/premz_list.txt", sep = ""), "."), sep =""), 
                               proc_mzml = paste(input_dir, str_remove(paste(input_table[i, "ResultFileNames"], "/processedSpectra.mzML", sep = ""), "."), sep =""),
                               db = "all", 
                               result_dir = input_table[i, "ResultFileNames"],
                               file_id = input_table[i, "File_id"], 
                               input_dir, 
                               no_of_candidates = 30,
                               ppmx = 15)

end.time <- Sys.time()

time.taken <- end.time - start.time
print(time.taken)
