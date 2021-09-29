# 8 Sept 2021
# For the moment, the decision is to have the same burn-in for 
# all iterations of the breeding scheme
# Future effort will have to go to seeing what variation is 
# caused by different burn-ins

## ----load packages----------------------------
if (!exists("init_num")) init_num <- 1
print("*************************")
print(paste("Loading packages for", init_num))
print("*************************")
ip <- installed.packages()
packages_used <- c("AlphaSimR", "dplyr",
                   "workflowr", "here", "devtools")
for (package in packages_used){
  if (!(package %in% ip[,"Package"])) install.packages(package)
}
library(dplyr)

packages_devel <- c("BreedSimCost")
for (package in packages_devel){
  if (!(package %in% ip[,"Package"])){
    devtools::install_github(paste0("jeanlucj/", package), ref="main",
                             build_vignettes=F)
  }
}
library(BreedSimCost)

here::i_am("LoadPackages.R")
