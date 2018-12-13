"""
LinearΩ: Stores Data in Linear Vector

# Properties
- Fast tracking (50 ns overhead)
- No overhead for linearization / delinearization
- Hence easy to sample from
- Good for optimization / inference methods which require linear interface
- Unique index for each rand value and hence:
  (i) Memory intensive
- Element lookup requires dictionary lookup and vector RAM so slower than Simple
"""
struct LinearΩ{I, AB, V} <: ΩBase{I}
  ids::Dict{I, AB}
  ωvec::Vector{V}
end

"Array of a linear array"
struct Segment
  startidx::Int
  shape::Dims
end

nelem(seg::Segment) = prod(seg.shape)

"lb:ub indices of ωvec subsumed by segment"
segrange(seg::Segment) = seg.startidx:seg.startidx+nelem(seg) - 1

LinearΩ() = LinearΩ{Vector{Int}, Segment, Float64}(Dict{Vector{Int}, Segment}(), Float64[])
LinearΩ{I, AB, V}() where {I, AB, V} = LinearΩ{I, AB, V}(Dict{I, V}(), V[])

linearize(lω::LinearΩ) = lω.ωvec
unlinearize(ωvec, lω::LinearΩ{I, AB, V}) where {I, AB, V}  = LinearΩ{I, AB, V}(lω.ids, ωvec)

"Sample a random component"
randunifkey(lω::LinearΩ) = rand(keys(lω.ids))

function resample!(lω::LinearΩ, id, proposal)
  segrng = segrange(lω.ids[id])
  lω.ωvec[segrng] .= proposal(lω.ωvec[segrng])
end

# Resolve
function resolve(lω::LinearΩ{I, Int, V}, id::I, T) where {I, V}
  if id in keys(lω.ids)
    lω.ωvec[lω.ids[id]]
  else
    val = rand(GLOBAL_RNG, T)
    push!(lω.ωvec, val)
    lω.ids[id] = length(lω.ωvec) # Store length explicitly?
    val
  end
end

function resolve(lω::LinearΩ{I, Segment, V}, id::I, T, dims::Dims) where {I, V}
  if id in keys(lω.ids)
    seg = lω.ids[id]
    n = prod(seg.shape) # Fixme: Store this?
    ωvec = lω.ωvec[seg.startidx:seg.startidx+n-1]
    reshape(ωvec, dims)
  else
    n = prod(dims)
    ωvec = rand(GLOBAL_RNG, T, dims)#::Array{randrtype(T), N}
    startidx = length(lω.ωvec) + 1
    append!(lω.ωvec, ωvec)
    lω.ids[id] = Segment(startidx, dims)
    reshape(ωvec, dims)
  end
end

function resolve(lω::LinearΩ{I, Segment, V}, id::I, T) where {I, V}
  if id in keys(lω.ids)
    seg = lω.ids[id]
    ωvec = lω.ωvec[seg.startidx]
  else
    val = rand(GLOBAL_RNG, T)
    startidx = length(lω.ωvec) + 1
    push!(lω.ωvec, val)
    lω.ids[id] = Segment(startidx, ())
    val
  end
end

Base.isempty(lω::LinearΩ) = isempty(lω.ωvec)
