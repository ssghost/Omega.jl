module OmegaDistributions

using Distributions: Normal, Bernoulli, UnivariateDistribution, Distribution, Uniform, quantile
import Distributions, OmegaCore
using OmegaCore.Var: liftapply, Member, StdUniform, StdNormal
import OmegaCore.Var
import OmegaCore.propagate

OmegaCore.Var.traitvartype(class::Type{<:Distribution}) = Var.TraitIsClass

@inline (d::Normal{T})(id, ω) where T =
  Member(id, StdNormal{T}())(ω) * d.σ + d.μ

# @inline Space.recurse(d::Distribution, id, ω) =
#   quantile(d, resolve(StdUniform(), id, ω))

@inline (d::Bernoulli)(id, ω) = 
  Member(id, StdUniform{Float64}())(ω) < d.p

@inline (d::UnivariateDistribution)(id, ω) =
  quantile(d, Member(id, StdUniform{Float64}())(ω))

invert(o::Normal, val) = (val / o.σ) - o.μ
invert(d::UnivariateDistribution, val) = cdf(d, val)

# Pointwise

function Base.broadcast(::Type{T}, arg1::Var.AbstractVariable, arg2) where {T <:Distribution}
  pw(T, arg1, arg2)
end

# Additional distributions 

export UniformDraw

"Element drawn uniformly from elements of set"
struct UniformDraw{T}
  elem::T
end

(u::UniformDraw)(i, ω) =
  u.elem[(i ~ Distributions.DiscreteUniform(1, length(u.elem)))(ω)]



function OmegaCore.propagate(rng, class::Member{<:Normal, I}, y) where {I}
  warn("fixme")
	x = class.class
	(class.id ~ StdNormal{Float64}()) => (y - x.μ) / x.σ
end

end