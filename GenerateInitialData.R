# Source this to generate initial data
if (!exists("init_num")) init_num <- 1
print(paste("GenerateInitialData.R Initialization", init_num))
if (testing){
  initDat <- readRDS(paste0("output/bg", init_num, ".rds"))
  budgets <- initDat[[1]]
  gains <- initDat[[2]]
} else{
  batch <- makeGrid(bsd)
  newBatchOut <- runBatch(batch, bsd)
  budgets <- newBatchOut %>% dplyr::select(contains("perc")) %>% as.matrix
  gains <- newBatchOut %>% dplyr::pull(response)
  saveRDS(list(budgets, gains), file=paste0("output/bg", init_num, ".rds"))
}
budgets <- as.matrix(budgets)
budgets <- budgets[,-4]
