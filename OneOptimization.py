import sys
# I am going to get the initialization number for an argument passed to the script
init_num = sys.argv[1]
# To know how the parameters work, know how many stages are in the breeding scheme
n_stages = int(sys.argv[2])
# In case you want to do more than one optimization for a given initialization
# But I think (hope) that will not be necessary
n_optimizations = int(sys.argv[3])
# Within each optimization, there will be n_iter calls to the acquisition function
n_iter = int(sys.argv[4])

TESTING = False

# ### Simple Breeding Scheme Optimization with BO
import torch

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print("Using {} device".format(device))
dtype = torch.double
torch.set_default_dtype(dtype)

# ### Objective function setup
# The objective function calls R by sourcing this runWithBudget script
import rpy2.robjects as ro
from rpy2.robjects import numpy2ri
numpy2ri.activate()

# Put the initialization number also in the R instance
ro.globalenv['init_num'] = init_num
# ### Load the packages needed in the R instance
ro.r.source('LoadPackages.R')

# X should be a one-dimensional torch tensor
def objective_func(X):
    ro.globalenv['percentages'] = X.numpy()
    ro.r.source('SourceToRunBatch.R')
    return torch.tensor(ro.globalenv['percentages']), torch.tensor(ro.globalenv['gain']).unsqueeze(-2)

# ### Model initialization
from botorch.models.gp_regression import SingleTaskGP
from botorch.models.transforms.outcome import Standardize
from gpytorch.mlls.exact_marginal_log_likelihood import ExactMarginalLogLikelihood
    
def initialize_model(train_x, train_obj):
    # define model for objective
    surrogate = SingleTaskGP(train_x, train_obj, outcome_transform=Standardize(m=1))
    mll = ExactMarginalLogLikelihood(surrogate.likelihood, surrogate)
    # fit the models
    fit_gpytorch_model(mll)
    return surrogate

# ### Start the overall loop
from botorch import fit_gpytorch_model
from botorch.acquisition.monte_carlo import qExpectedImprovement
from botorch.optim import optimize_acqf
from botorch.sampling.samplers import SobolQMCNormalSampler
from botorch.exceptions import BadInitialCandidatesWarning

import time
import warnings

warnings.filterwarnings('ignore', category=BadInitialCandidatesWarning)
warnings.filterwarnings('ignore', category=RuntimeWarning)

MC_SAMPLES = 256
NUM_RESTARTS = 30 # 10 * input_dim
RAW_SAMPLES = 600 # 200 * input_dim

# Storage for the optimizations
stor_train_x = []
stor_train_obj = []
stor_traces = []

print(f"\nInitialization {init_num:>2}", end="")
# ### Initialize the scheme and run the burn-in cycles
ro.r.source('BreedSimCostSetup.R')
budget_constraints = torch.tensor(ro.globalenv['budget_constraints'])
# Set this up so that only n_stages parameters are being captured
# So, they have to sum to less than 1.0
mb = 1.0 - budget_constraints[0] - budget_constraints[1]
bounds = torch.tensor(
    [[budget_constraints[0], 0.0, 0.0], [mb] * n_stages],
    device=device, dtype=dtype)

lr = budget_constraints[4]
inequality_constraints = [
    (torch.tensor([i for i in range(n_stages)]), torch.tensor([-1.0] * (n_stages)), -(1.0 - budget_constraints[1])), 
    (torch.tensor([0, 1]), torch.tensor([1.0, -budget_constraints[2]]), 0.0),
    (torch.tensor([1, 2]), torch.tensor([1.0, -budget_constraints[3]]), 0.0),
    (torch.tensor([i for i in range(n_stages)]), torch.tensor([lr, lr, 1+lr]), lr),
    ]

for optimization in range(n_optimizations):
    print(f"\nOptimization {optimization:>2} of {n_optimizations} ", end="")
    # Initial data
    ro.globalenv['testing'] = TESTING
    ro.r.source('GenerateInitialData.R')
    train_x = torch.tensor(ro.globalenv['budgets'])
    train_obj = torch.tensor(ro.globalenv['gains']).unsqueeze(-1)
    best_observed_obj = train_obj.max().item()
    best_observed_vec = [best_observed_obj]

    # run n_iter rounds of BayesOpt after the initial random batch
    for iteration in range(n_iter):
        print(f"\nInitialization {init_num:>2} Optimization {optimization:>2} Iteration {iteration:>2} of {n_iter} ", end="")
        surrogate = initialize_model(train_x, train_obj)
    
        # define the qEI using a QMC sampler [I don't understand what this does]
        qmc_sampler = SobolQMCNormalSampler(num_samples=MC_SAMPLES)
            
        # for best_f, use the best observed noisy values as an approximation
        # What does passing the objective function on to the acquisition function do?
        qEI = qExpectedImprovement(
            model=surrogate, 
            best_f=best_observed_obj,
            sampler=qmc_sampler, 
        )

        # optimize the acquisition function
        candidates, _ = optimize_acqf(
            acq_function=qEI,
            bounds=bounds,
            inequality_constraints=inequality_constraints,
            q=1,
            num_restarts=NUM_RESTARTS,
            raw_samples=RAW_SAMPLES,  # used for intialization heuristic
            options={"batch_limit": 5, "maxiter": 200},
        )

        print(candidates)

        # get new observation
        new_perc, new_obj = objective_func(candidates)
                    
        # update training points
        train_x = torch.cat([train_x, new_perc])
        train_obj = torch.cat([train_obj, new_obj])
        best_observed_obj = train_obj.max().item()
        best_observed_vec.append(best_observed_obj)
    stor_train_x.append([train_x.numpy()])
    stor_train_obj.append([train_obj.numpy()])
    stor_traces.append(best_observed_vec)
    ro.globalenv['train_x'] = stor_train_x
    ro.globalenv['train_obj'] = stor_train_obj
    ro.globalenv['traces'] = stor_traces
    ro.r.source('StoreOptData.R')
