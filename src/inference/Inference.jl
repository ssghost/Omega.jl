"Inference Algorithms"
module Inference

using Spec
using ..Omega: RandVar, applytrackerr, indomain, Wrapper, logerr,
               UTuple, Ω, applynotrackerr, SimpleΩ, LinearΩ, Segment, randunifkey,
              resample, resample!, update, cond, randtuple, nelem,
               fluxgradient, gradient, linearize, unlinearize, err

import ..Omega
  using ProgressMeter
using Flux
using Callbacks
import UnicodePlots

"Optimization Algorithm"
abstract type OptimAlgorithm end

"Posterior Sampling Algorithm"
abstract type SamplingAlgorithm end

"Is the inference algorithm approximate?"
function isapproximate end

"Default probability space type to use"
function defΩ end

include("transforms.jl")# Transformations from [0, 1] to R, etc
include("callbacks.jl") # Common Inference Functions

# Sampling
include("rand.jl")      # Sampling
include("rs.jl")        # Rejection Sampling
include("mi.jl")        # Metropolized Independent Sampling
include("ssmh.jl")      # Single Site Metropolis Hastings
include("hmc.jl")       # Hamiltonian Monte Carlo
include("hmcfast.jl")   # Faster Hamiltonian Monte Carlo
include("replica.jl")   # Replica Exchange
include("dynamichmc.jl")# Dynamic Hamiltonion Monte Carlo
# include("sghmc.jl")     # Stochastic Gradient Hamiltonian Monte Carlo
# include("relandscape.jl")  # Variantional Sampling through relandscape

# Optimization
include("argmax.jl")     # NLopt based optimization
include("nlopt.jl")     # NLopt based optimization

export  isapproximate,

        RejectionSample,
        MI,
        SSMH,
        SSMHDrift,
        HMC,
        # SGHMC,
        HMCFAST,
        Replica,

        RejectionSampleAlg,
        MIAlg,
        SSMHAlg,
        HMCAlg,
        # SGHMCAlg,
        HMCFASTAlg,
        RelandscapeAlg,
        Relandscape,
        DynamicHMC,
        DynamicHMCAlg,

        defalg,
        defcb,
        defΩ,
        defΩProj,

        plotrv,
        plotscalar,
        default_cbs,
        default_cbs_tpl,
        default_cbs


end
