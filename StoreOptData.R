
here::i_am("StoreOptData.R")

btOut <- list(train_x, train_obj, traces)
saveRDS(btOut, file=here::here("output", paste0("BoTorchOut", init_num, ".rds"))
