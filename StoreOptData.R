
btOut <- list(train_x, train_obj, traces)
saveRDS(btOut, file=paste0("output/BoTorchOut", init_num, "_", iteration, ".rds"))
