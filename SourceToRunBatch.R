# Function to source to get results needed for Bayesian Optimization
# Python rpy2 should have made the percentages vector
# burnedInBSD should exist from BreedSimCostSetup
# runWithBudget returns
# c(percentages,
# start_breedPopMean, start_breedPopSD, start_varCandMean,
# end_breedPopMean, end_breedPopSD, end_varCandMean,
# realizedBudget)

percentages <- cbind(percentages, 1 - rowSums(percentages))
idx <- ncol(percentages)+1
percList <- lapply(apply(percentages, 1, list), unlist)

rbOut <- runWithBudget(percList, bsd=burnedInBSD)
percentages <- rbOut[,1:3]
gain <- rbOut[,idx+5] - rbOut[,idx]
