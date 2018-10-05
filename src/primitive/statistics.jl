## Distributional Functions
## ========================
# "Sample approximation (using `n` samples)  to expectation of `x`"
# mean(x::RandVar{<:Real}, n=10000) = sum((rand(x, alg = RejectionSample) for i = 1:n)) / n
# mean(x::RandVar{T}, n=10000) where {T <: RandVar{<:Real}} =
#   RandVar{Float64, false}(mean, (x, n), 0)

# "Sample approximation (using `n` samples) to variance of `x`"
# function var(x::RandVar{<:Real}, n=10000)
#   var([rand(x) for i = 1:n])
# end

# "Sample variusing ..Omega: ance (using `n` samples)"
# function var(x::RandVar{T}, n=10000) where {T <: RandVar{<:Real}}
#   RandVar{Float64, false}(var, (x, n))
# end

# mean(xs::RandVar{<:Array}) = RandVar{Float64, false}(mean, (xs,))

# "Probability that `x` is `true`"
# prob(x::RandVar{T}, n) where {T <: Bool} = mean(x, n)
# prob(x::RandVar{T}, n = 10000) where { T<: RandVar{Bool}} = RandVar{Float64}(prob, (x, n))
# lift(:prob, 1)


# Issues.
# Must expect that type inference may fail, and allow providing of type
# Also allow separate functions
# 

# Specializations
const unidistattrs = [:succprob, :failprob, :maximum, :minimum, :islowerbounded,
                      :isupperbounded, :isbounded, :std, :median, :mode, :modes,
                      :skewness, :kurtosis, :isplatykurtic, :ismesokurtic,
                      :isleptokurtic, :entropy, :mean]

for func in unidistattrs
  expr = 
  quote
    $func(x::RandVar, israndvar::Type{Val{false}}) = Djl.$func(distribution(x))
    $func(x::RandVar, israndvar::Type{Val{true}}) = $(:l *ₛ func)(x)
    $(:l *ₛ func)(x::RandVar) = ciid($func, x, Val{false})
    $func(x::RandVar) = $func(x, Val{elemtype(x) <: RandVar})
  end
  @show expr
  eval(expr)
end


# const bindistattrs = [:entropy, :mgf, :cf, :pdf, :logpdf, :loglikelihood, :cdf,
#                       :logcdf, :ccdf, :logccdf, :quantile, :cquantile,
#                       :invlogcdf, :invlogccdf]

# for func in bindistattrs
#   expr = 
#   quote
#     $func(x::PrimRandVar, et::Type{<:Real}) = Djl.$func(distribution(x))
#     $func(x::RandVar, et::Type{<:RandVar}, t) = ciid(mean, x)
#     $func(x::RandVar, t) = $func(x, elemtype(x))
#   end
#   eval(expr)
# end
# Djl.entropy(x::RandVar) = entropy(distribution(x))
# Djl.entropy(x::RandVar, base) = entropy(distribution(x), base)

# Djl.mgf(x::RandVar, t) = mgf(distribution(x), t)
# Djl.cf(x::RandVar, t) = cf(distribution(x), t)

# Djl.pdf(x::RandVar, t) = pdf(distribution(x), t)
# Djl.logpdf(x::RandVar, t) = logpdf(distribution(x), t)
# Djl.loglikelihood(x::RandVar, t) = loglikelihood(distribution(x), t)

# Djl.cdf(x::RandVar, t) = cdf(distribution(x), t)
# Djl.logcdf(x::RandVar, t) = logcdf(distribution(x), t)

# Djl.ccdf(x::RandVar, t) = ccdf(distribution(x), t)
# Djl.logccdf(x::RandVar, t) = logccdf(distribution(x), t)

# Djl.quantile(x::RandVar, t) = quantile(distribution(x), t)
# Djl.cquantile(x::RandVar, t) = cquantile(distribution(x), t)

# Djl.invlogcdf(x::RandVar, t) = invlogcdf(distribution(x), t)
# Djl.invlogccdf(x::RandVar, t) = invlogccdf(distribution(x), t)

# Converions between Distributions and Omega

djldist(::T, params...) where {T <: RandVar} = djltype(T)(params...)

djltype(::Type{<:Normal}) = Djl.Normal
djltype(::Type{<:Beta}) = Djl.Beta
djltype(::Type{<:Bernoulli}) = Djl.Bernoulli
djltype(::Type{<:ReplaceRandVar{Prim}}) where Prim = djltype(Prim)

mayberand(x::RandVar) = rand(x)
mayberand(c) = c

"Convert an RID into a Distributions.jl `Distribution``"
function distribution(rv::RandVar)
  θs = params(rv)
  θisconst = isconstant.(θs)
  θsc = mayberand.(θs)
  djldist(rv, θsc...)
end
@spec all(θisconst) || throw("All params must be constant to convert to Distributions")

