# __precompile__(false)
"A Library for Causal and Higher-Order Probabilistic Programming"
module Omega

t = 3

using Flux
using Spec
using UnicodePlots
using DocStringExtensions: FIELDS, SIGNATURES, TYPEDEF
using Cassette  


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
export Ω, uid, @id, SimpleΩ, LinearΩ

# RandVar
include("randvar/randvar.jl" )            # Random variables
include("randvar/urandvar.jl")            # Random variables
include("randvar/randvarapply.jl")        # Random variable application to ω::Ω
include("randvar/ciid.jl")                # Conditionally i.i.d. RandVars
include("randvar/elemtype.jl")            # Infer Element Type
export RandVar, MaybeRV, ciid, isconstant, elemtype, params

# Conditioning
include("cond.jl")                # Conditioning
export cond

# Lifted random variable operatiosn
include("lift/containers.jl")     # Array/Tuple primitives
export randarray, randtuple

# Higher-Order Inference
include("higher/Higher.jl")
using .Higher
export rcd, rid, ∥

# Lifting functions to RandVar domain
include("lift/lift.jl")           
export @lift, lift

# Soft Inference
include("soft/soft.jl")           # Soft Booleans / logic
export  SoftBool,
        softeq,
        softlt,
        softgt,
        >ₛ,
        >=ₛ,
        <=ₛ,
        <ₛ,
        ==ₛ,
        err,
        logerr,

        # Kernels
        kse,
        kseα,
        kf1,
        kf1β,
        withkernel,
        atα,
        @atα,

        indomainₛ,
        applynotrackerr,
        applytrackerr

# Gradient
include("gradient.jl")
export gradient

# Inference Algorithms
include("inference/Inference.jl")
using .Inference
export  isapproximate,

        RejectionSample,
        SSMH,
        HMC,
        # SGHMC,
        HMCFAST,
        Relandscape,
        Replica,

        RejectionSampleAlg,
        SSMHAlg,
        HMCAlg,
        # SGHMCAlg,
        HMCFASTAlg,
        RelandscapeAlg,
        ReplicaAlg,
        NUTS,
        NUTSAlg,

        defalg,
        defcb,
        defΩ,
        defΩProj,

        plotrv,
        plotscalar,
        default_cbs,
        HMCStep,
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

export  succprob,
        failprob,
        maximum,
        minimum,
        islowerbounded,                    
        isupperbounded,
        isbounded,
        std,
        median,
        mode,
        modes,

        skewness,
        kurtosis,
        isplatykurtic,
        ismesokurtic,

        isleptokurtic,
        entropy,
        mean,
        prob,
        lprob

# Lifted distributional functions
export  lsuccprob,
        lfailprob,
        lmaximum,
        lminimum,
        lislowerbounded,                    
        lisupperbounded,
        lisbounded,
        lstd,
        lmedian,
        lmode,
        lmodes,

        lskewness,
        lkurtosis,
        lisplatykurtic,
        lismesokurtic,

        lisleptokurtic,
        lentropy,
        lmean

# Neural Network Stuff
include("flux.jl")
export Dense

end
