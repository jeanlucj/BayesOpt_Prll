# BayesOpt_Prll

1. Run parallelizeOptimizations.R
2.   It will mclapply a function that initiates the creation of a breeding scheme and its optimization
3.   That is done by calling a Python script that controls the optimization
4.     The Python controller calls R to simulate the breeding scheme which returns the gain
