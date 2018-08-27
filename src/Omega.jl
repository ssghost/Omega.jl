# __precompile__(false)
"A Library for Causal and Higher-Order Probabilistic Programming"
module Omega

using Flux
using Spec
using ZenUtils
using UnicodePlots
using Compat

import Random
import Random: GLOBAL_RNG, AbstractRNG
import Statistics: mean, var, quantile

# Util
include("util/Util.jl")
using .Util
export ntranspose

# Core
include("space/Space.jl")         # UIDs
using .Space
export Ω, uid, @id, SimpleΩ

# RandVar
include("randvar/randvar.jl" )            # Random variables
include("randvar/urandvar.jl")            # Random variables
include("randvar/randvarapply.jl")        # Random variable application to ω::Ω
include("randvar/ciid.jl")                # Conditionally i.i.d. RandVars
export RandVar, MaybeRV, ciid, isconstant

# Conditioning
include("cond.jl")                # Conditioning
export cond

# Higher-Order Inference
include("higher/Higher.jl")
using .Higher
export rcd, rid, ∥

# Lifted random variable operatiosn
include("lift/containers.jl")     # Array/Tuple primitives
export  randarray, randtuple

# Lifting functions to RandVar domain
include("lift/lift.jl")           
export @lift, lift

# Soft Inference
include("soft/kernels.jl")        # Kernels
include("soft/soft.jl")           # Soft logic
include("soft/trackerror.jl")     # Tracking error
export  SoftBool,
        softeq,
        softlt,
        softgt,
        ≊,
        ⪆,
        ⪅,
        >ₛ,
        >=ₛ,
        <=ₛ,
        <ₛ,
        ==ₛ,

        # Kernels
        kse,
        kseα,
        kf1,
        kf1β,
        withkernel,

        indomain,
        applywoerror,
        trackerrorapply

# Gradient
include("gradient.jl")
export gradient

# Inference Algorithms
include("inference/Inference.jl")
using .Inference
export  isapproximate,

        RejectionSample,
        MI,
        SSMH,
        SSMHDrift,
        HMC,
        # SGHMC,
        HMCFAST,

        RejectionSampleAlg,
        MIAlg,
        SSMHAlg,
        SSMHDriftAlg,
        HMCAlg,
        # SGHMCAlg,
        HMCFASTAlg,

        defalg,
        defcb,
        defΩ,
        defΩProj,

        everyn,
        →,
        idcb,
        throttle,
        plotrv,
        default_cbs,
        Inside,
        Outside,
        default_cbs_tpl,
        default_cbs

# Causal Inference
include("causal/Causal.jl")
using .Causal
export replace

# Library
include("primitive/Prim.jl")
using .Prim
export  bernoulli,
        betarv,
        β,
        categorical,
        # dirichlet,
        exponential,
        gammarv,
        Γ,
        invgamma,
        kumaraswamy,
        logistic,
        # mvnormal,
        normal,
        poisson,
        rademacher,
        uniform

# Neural Network Stuff
include("flux.jl")
export Dense

end
