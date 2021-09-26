# Run multiple parallel optimizations
library(parallel)

n_initializations <- 6
n_stages <- 3
n_optimizations <- 1
n_iterations <- 500
n_cores <- 6

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

callOneOptimization <- function(init_num=1, n_stages=3,
                                n_optimizations=1, n_iter=500){
  outFile <- paste0("optOutFile", init_num, ".txt")
  callPyCommand <- paste("python OneOptimization.py", init_num, n_stages,
                         n_optimizations, n_iter, ">", outFile, "&")
  system(callPyCommand, intern = FALSE,
         ignore.stdout = FALSE, ignore.stderr = FALSE,
         wait = TRUE, input = NULL, timeout = 0)
}

tst <- mclapply(1:n_initializations, callOneOptimization,
         n_stages=n_stages, n_optimizations=n_optimizations,
         n_iterations=n_iterations,
         mc.preschedule=F, mc.cores=n_cores)
