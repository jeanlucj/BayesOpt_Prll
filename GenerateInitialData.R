# Source this to generate initial data

if (testing){
  initDat <- readRDS("output/bg.rds")
  budgets <- initDat[[1]]
  gains <- initDat[[2]]
} else{
  batch <- makeGrid(bsd)
  newBatchOut <- runBatch(batch, bsd)
  budgets <- newBatchOut %>% dplyr::select(contains("perc")) %>% as.matrix
  gains <- newBatchOut %>% dplyr::pull(response)
  saveRDS(list(budgets, gains), file="output/bg.rds")
}
budgets <- as.matrix(budgets)
budgets <- budgets[,-4]
