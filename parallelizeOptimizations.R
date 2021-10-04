# Run multiple parallel optimizations
library(parallel)

debug <- FALSE
if (debug){
  n_initializations <- 2
  n_optimizations <- 1
  n_iterations <- 3
} else{
  n_initializations <- 6
  n_optimizations <- 1
  n_iterations <- 250
  n_cores <- 6
}
n_stages <- 3

random_seed <- 567890
set.seed(random_seed)
initRandSeeds <- round(runif(n=n_initializations, min=1, max=1e9))

# Function to call one optimization in Python
# This function will be called using mclapply to parallelize optimizations
# These are the first lines of the python script
# init_num = sys.argv[1]
# To know how the parameters work, know how many stages in the breeding scheme
# n_stages = int(sys.argv[2])
# In case you want to do more than one optimization for a given initialization
# n_optimizations = int(sys.argv[3])
# Within each optimization, n_iter acquisition function calls
# n_iter = int(sys.argv[4])

callOneOptimization <- function(init_num=round(runif(n=1, min=1, max=1e9)),
                                n_stages=3, n_optimizations=1, n_iter=500){
  outFile <- paste0("optOutFile", init_num, ".txt")
  set.seed(init_num)
  callPyCommand <- paste("python OneOptimization.py", init_num, n_stages,
                         n_optimizations, n_iter, ">", outFile, "&")
  system(callPyCommand, intern = FALSE,
         ignore.stdout = FALSE, ignore.stderr = FALSE,
         wait = TRUE, input = NULL, timeout = 0)
}

if (debug){
  tst <- lapply(initRandSeeds, callOneOptimization,
                  n_stages=n_stages, n_optimizations=n_optimizations,
                  n_iter=n_iterations)
} else{
  tst <- mclapply(initRandSeeds, callOneOptimization,
                  n_stages=n_stages, n_optimizations=n_optimizations,
                  n_iter=n_iterations,
                  mc.preschedule=F, mc.cores=n_cores)
}
