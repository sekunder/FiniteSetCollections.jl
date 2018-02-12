
abstract type AbstractSimplicialComplex <: AbstractFiniteSetCollection end

function show(io::IO, K::AbstractSimplicialComplex)
    println(io, "$(dim(K))-dimensional simplcial complex")
    println(io, "V = {$(join(",",vertices(K)))}")
    println(io, "max K = {$(join(",",facets(K)))}")
end

################################################################################
# General functions, defined for any subtype. Not always the most efficient
# implementations.
################################################################################
"""
    dim(K)

The dimension of `K`, defined as the maximum size of a face of `K` minus 1. If
`K` is the void complex (i.e. `K` has no faces), throws an `ArgumentError`.

"""
dim(K::AbstractSimplicialComplex) = maximum(map(length, facets(K))) - 1

"""
    link(sigma, K)

The link of `sigma` in `K`.

``link_σ(K) = {τ ∈ K : σ ∩ τ = ∅, σ ∪ τ ∈ K}``
"""
function link{T<:AbstractSimplicialComplex}(sigma,K::T)
    newFacets = Vector()
    for F in facets(K)
        if issubset(sigma, F)
            push!(newFacets, setdiff(F,sigma))
        end
    end
    return T(newFacets)
end

"""
    del(tau, K)

The deletion of `tau` from `K`. This is the set faces in `K` which are _not_
cofaces of `tau`. For "deletion" to mean "faces which do not intersect `tau`",
compute the complement of `tau` in `K`'s vertex set and use `res` to restrict to
that set.

``del_τ(K) = {σ ∈ K : τ ⊏̸ σ}``
"""
function del{T<:AbstractSimplicialComplex}(tau, K::T)
    return T(map(F -> setdiff(F,tau), collect(facets(K))))
end

"""
    res(Vprime, K)

The restriction of `K` to `Vprime`.

``res_{V'}(K) = {σ ∈ K : σ ⊆ V'}``
"""
function res{T<:AbstractSimplicialComplex}(Vprime, K::T)
    return T(map(F -> intersect(F,Vprime),collect(facets(K))))
end

################################################################################
# BEGIN CONCRETE SUBTYPES OF ASC
################################################################################

# FACETLIST
"""
    FacetList

A simplicial complex, stored as a list of its facets. Low storage, high
computation time (generally).
"""
struct FacetList{V} <: AbstractSimplicialComplex
    vertices::Vector{V}
    facets::BitMatrix # rows as facets
end
function FacetList(L)
    V = union(L...)
    B = falses(length(L),length(V))
    keep = falses(length(L))
    for i = 1:length(L)
        keep[i] = all(map(G -> !issubset(L[i],G), L[i+1:end]))
        if keep[i]
            B[i,indexin(L[i],V)] = true
        end
    end
    B = B[keep,:]
    return FacetList(V,B)
end
function FacetList(C::AbstractFiniteSetCollection)
    return FacetList(collect(facets(C)))
end

vertices(K::FacetList) = K.V

#TODO iteration functions to iterate over *all* faces of K
function start(K::FacetList)
end
function next(K::FacetList, state)
end
function done(K::FacetList, state)
end

# Functions for iterating over the facets of K.
start{V}(maxK::MaximalSetIterator{FacetList{V}}) = 0
next{V}(maxK::MaximalSetIterator{FacetList{V}}, state) = (maxK.C.vertices[maxK.C.facets[state+1,:]], state+1)
done{V}(maxK::MaximalSetIterator{FacetList{V}}, state) = state >= size(maxK.C.facets,1)
