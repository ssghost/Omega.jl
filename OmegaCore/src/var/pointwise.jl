# module Pointwise

export pw, l, ₚ, PwVar, liftapply, PointwiseStyle
import AndTraits
 
"""
Pointwise application.

Pointwise function application gives meaning to expressions such as `x + y`  when `x` and `y` are functions.
That is `x + y` is the function `ω -> x(ω) + y(ω)`.

An argument can be either __lifted__ or __not lifted__.
For example in `x = 1 ~  Normal(0, 1); y = pw(+, x, 3)`, `x` will be lifted but `3` will not be in the sense that
`y` will resolve to `ω -> x(ω) + 3` and not `ω -> x(ω) + 3(ω)`.

`pw` uses some reasonable defaults for what to lift and what not to lift, but to have more explicit control use `l` and `dl` to
lift and dont lift respectively.

Example:
```
using OmegaCore
x = 1 ~ StdUniform{Float64}()
y = pw(+, x, 4)

flip(ω::Ω) = x(ω) > 0.5

f(ω::Ω) = flip(ω) ? sqrt : sin
randsample(pw(map, f, [0, 1, 2]))
randsample(pw(map, sqrt, [0, 1, 2])) # Will error!
randsample(pw(map, dl(sqrt), [0, 1, 2]))
randsample(pw(f, 3))

g(ϵ) = ω::Ω -> x(ω) + ϵ
u = 1 ~ StdNormal{Float64}()
g.(u) := ω::Ω -> g(u(ω))(ω)

g(ϵ) = (i, ω::Ω) -> i ~ Normal(ω, 0, 1) + ϵ
u = 1 ~ StdNormal{Float64}()
g.(u) := (i, ω::Ω) -> g(u(ω))(i, ω) # This is what I'd want, and the result should be a class, but i cant tell that based on
# Types of u or types of g (well, in principle I could for type of g but not in Julia)


```
"""
# 1. f(::AbstractVariableOrClass, ω) = ...
# 2. Different types, so we decide when we construct them

struct PwClass{ARGS, D} <: AbstractClass
  f::D
  args::ARGS
  PwClass(f::F, args::A) where {F, A} = new{A, F}(f, args)
  PwClass(f::Type{T}, args::A) where {T, A} = new{A, Type{T}}(f, args)
end

(p::PwClass{Tuple{T1}})(i, ω) where {T1} =
  lift_output(p.f(liftapply(p.args[1], i, ω)), i, ω)

(p::PwClass{Tuple{T1, T2}})(i, ω) where {T1, T2} =
  lift_output(p.f(liftapply(p.args[1], i, ω), liftapply(p.args[2], i, ω)), i, ω)

struct PwVar{ARGS, D} <: AbstractVariable
    f::D
  args::ARGS
  PwVar(f::F, args::A) where {F, A} = new{A, F}(f, args)
  PwVar(f::Type{T}, args::A) where {T, A} = new{A, Type{T}}(f, args)
end

# FIXME: What about more than two arguments
pw(f::F, arg1::A1) where {F, A1} =
  inferpwtype(f, arg1, AndTraits.conjointraits(traitvartype(F), traitvartype(A1)))
pw(f::F, arg1::A1, arg2::A2) where {F, A1, A2} =
  inferpwtype(f, arg1, arg2, AndTraits.conjointraits(traitvartype(F), traitvartype(A1), traitvartype(A2)))

# FIXME: Feel like this wil likely break type inference
pw(f, args...) = 
  inferpwtype(f, args..., AndTraits.conjointraits(map(typeof, args)...))

# inferpwtype(AndTraits.traitmatch(TraitIsVariable, TraitIsClass)) = PwClass(f, args)

inferpwtype(f, arg1, ::AndTraits.traitmatch(TraitIsVariable, TraitIsClass)) = PwClass(f, (arg1,))
inferpwtype(f, arg1, ::AndTraits.traitmatch(TraitIsClass)) = PwClass(f, (arg1,))
inferpwtype(f, arg1, ::AndTraits.traitmatch(TraitIsVariable)) = PwVar(f, (arg1,))
inferpwtype(f, arg1, ::AndTraits.traitmatch(TraitUnknownVariableType, TraitIsVariable, TraitIsClass)) = PwClass(f, (arg1,))

inferpwtype(f, arg1, arg2, ::AndTraits.traitmatch(TraitIsVariable, TraitIsClass)) = PwClass(f, (arg1, arg2))
inferpwtype(f, arg1, arg2, ::AndTraits.traitmatch(TraitIsClass)) = PwClass(f, (arg1, arg2))
inferpwtype(f, arg1, arg2, ::AndTraits.traitmatch(TraitIsVariable)) = PwVar(f, (arg1, arg2))
inferpwtype(f, arg1, arg2,  ::AndTraits.traitmatch(TraitUnknownVariableType, TraitIsVariable, TraitIsClass)) = PwClass(f, (arg1, arg2))

Base.show(io::IO, p::Union{PwVar, PwClass}) = print(io, p.f, "ₚ", p.args)

# Lifting
struct LiftBox{T}# <: ABox
  val::T
end
"`l(x)` constructs object that indicates that `x` should be applied pointwise.  See `pw`"
l(x) = LiftBox(x)

@inline unbox(x::LiftBox) = x.val
@inline unbox(x) = x

@inline liftapply(f::T, ω) where T = liftapplyt(traitvartype(T), f, ω)
@inline liftapply(f::T, i, ω) where T = liftapplyt(traitvartype(T), f, i, ω)

@inline liftapply(f::Ref, ω) = f[]
@inline liftapply(f::Ref, i, ω) = f[]

@inline liftapply(f::LiftBox, i, ω) = liftapply(unbox(f), i, ω)

# Random Variable
@inline liftapplyt(::AndTraits.traitmatch(TraitIsVariable), f, ω) = f(ω)
@inline liftapplyt(::AndTraits.traitmatch(TraitUnknownVariableType), f, ω) = f

# Class
@inline liftapplyt(::AndTraits.traitmatch(TraitIsVariable), f, i, ω) = f(ω)
@inline liftapplyt(::AndTraits.traitmatch(TraitIsClass), f, i, ω) = f(i, ω)
@inline liftapplyt(::AndTraits.traitmatch(TraitUnknownVariableType), f, i, ω) = f

# Handle output function might return random variable
@inline lift_output(op::O, ω) where {O} = lift_output(traitvartype(O), op, ω)
@inline lift_output(::AndTraits.traitmatch(TraitUnknownVariableType), op, ω) = op
@inline lift_output(::AndTraits.traitmatch(TraitIsVariable), op, ω) = op(ω)

# Class output 
@inline lift_output(op::O, i, ω) where {O} = lift_output(traitvartype(O), op, i, ω)
@inline lift_output(::AndTraits.traitmatch(TraitUnknownVariableType), op, i, ω) = op
@inline lift_output(::AndTraits.traitmatch(TraitIsVariable), op, i, ω) = op(ω)

recurse(p::PwVar{Tuple{T1}}, ω) where {T1} =
  lift_output(p.f(liftapply(p.args[1], ω)), ω)  # FIXME: Handle case when f is as rv{function}

recurse(p::PwVar{Tuple{T1, T2}}, ω) where {T1, T2} =
  lift_output(p.f(@show(liftapply(p.args[1], ω)), @show(liftapply(p.args[2], ω))), ω)

recurse(p::PwVar{<:Tuple}, ω) =
  lift_output(p.f(map(arg -> liftapply(arg, ω), p.args)...), ω)


## Broadcasting
struct PointwiseStyle <: Broadcast.BroadcastStyle end
Base.BroadcastStyle(::Type{<:Union{AbstractVariable, AbstractClass}}) = PointwiseStyle()
Base.broadcastable(x::Union{AbstractVariable, AbstractClass}) = x

Base.broadcasted(::PointwiseStyle, f, args...)  = pw(f, args...)
Base.BroadcastStyle(::PointwiseStyle, ::Base.Broadcast.DefaultArrayStyle{0}) = PointwiseStyle()

# Handle `f` is random variable over functions
Base.broadcast(f::Union{AbstractVariable, AbstractClass}, args...) = pw(f, args...)
Base.broadcast(f::Union{AbstractVariable, AbstractClass}, args::Vararg{Number}) = pw(f, args...)