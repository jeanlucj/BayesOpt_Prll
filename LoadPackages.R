## ----load packages----------------------------
if (!exists("init_num")) init_num <- 1
print("*************************")
print(paste("Loading packages for", init_num))
print("*************************")
ip <- installed.packages()
packages_used <- c("AlphaSimR", "dplyr")
for (package in packages_used){
  if (!(package %in% ip[,"Package"])) install.packages(package, repos="https://cloud.r-project.org")
}
library(dplyr)

system("R CMD INSTALL -l /Library/Frameworks/R.framework/Versions/4.0/Resources/library BreedSimCost.tar.gz")
library(BreedSimCost)
