## ----load packages----------------------------
if (!exists("init_num")) init_num <- 1
print("*************************")
print(paste("Loading packages for", init_num))
print("*************************")

ip <- installed.packages()
packages_used <- c("AlphaSimR", "BreedSimCost", "dplyr")
for (package in packages_used){
  if (!(package %in% ip[,"Package"])) stop(paste("Missing package", package))
}

library(dplyr)
library(BreedSimCost)
