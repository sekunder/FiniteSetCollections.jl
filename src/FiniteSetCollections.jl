"""
    FiniteSetCollections

Module provides data types and methods for performing computations with finite set collections, such as combinatorial codes and simplicial complexes.
"""
module FiniteSetCollections

################################################################################
### Import statements
################################################################################
import Base: show, start, next, done

################################################################################
### Abstract type and general utility function definitions
################################################################################
abstract type AbstractFiniteSetCollection end

struct MaximalSetIterator{T<:AbstractFiniteSetCollection}
    C::T
end

"""
    facets(C::AbstractFiniteSetCollection)

Returns an iterator over the maximal (by set inclusion) elements of C
"""
facets{T<:AbstractFiniteSetCollection}(C::T) = MaximalSetIterator{T}(C)

################################################################################
### Include external files
################################################################################
include("SimplicialComplex.jl")

################################################################################
### Define type aliases for ease of use
################################################################################
const SimplicialComplex = FacetList

end # module
