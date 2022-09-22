install.packages(c("listenv", "future"))


library(parallel)
library(doParallel)
library(future)
library(iterators)
library(listenv)

options(future.globals.maxSize = 8 * 1024^3) # increase dataset size limit taken by future to 8GB

# detects number of cores
n.cores <- parallel::detectCores()


plan(list(
  tweak(multisession, workers = ((n.cores + 5) %/% 3) %/% 2),
  tweak(multisession, workers = ((n.cores + 5) %/% 3) %/% 2),
  tweak(multisession, workers = 3)
))


start.time <- Sys.time()

input_dir <- getwd()

source(paste(getwd(),"/Workflow_R_Functions.r", sep = ""))

input_table <- read.csv(paste(input_dir,"/input_table.csv", sep = ""))
input_table

input_table_idxs <- listenv()

#run_metfrag(paste(input_dir, str_remove(paste(input_table[i, "ResultFileNames"], "/insilico/metparam_list.txt", sep = ""), "."), sep =""))

for (i in 1:nrow(input_table)){
    input_table_idxs[[i]] <- future({
        
        sirius_adduct(input_dir, 
                             x = input_table[i, "ResultFileNames"], 
                             SL = FALSE)
        

        metfrag_param(x = paste(input_dir, str_remove(paste(input_table[i, "ResultFileNames"], "/insilico/MS1DATAsirius.csv", sep = ""), "."), sep =""),
                      result_dir = input_table[i, "ResultFileNames"], 
                      input_dir, 
                      sl_mtfrag = NA, 
                      SL = FALSE, 
                      ppm_max = 5, 
                      ppm_max_ms2= 15)
        
        run_metfrag(paste(input_dir, str_remove(paste(input_table[i, "ResultFileNames"], "/insilico/metparam_list.txt", sep = ""), "."), sep =""))
        
    })
    
}

input_table_idxs <- as.list(input_table_idxs)
v_input_table_idxs <- future::value(input_table_idxs)

end.time <- Sys.time()

time.taken <- end.time - start.time
print(time.taken)
