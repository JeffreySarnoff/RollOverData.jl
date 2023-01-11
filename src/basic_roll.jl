#=
    Basic rolls neither provide padding nor offer tapering.
    A basic roll always drops those data elements at the 
      start of the data which cannot be completely resolved
      under the windowed function: this eliminates the initial
      (windowsize - 1) evaluands from the result.
   The initial (windowsize - 1) data elements are used to
      resolve the first value of the windowed function.

   for example
       data = [1,2,3,4,5,6]; windowspan = 4; fn = mean;
       datalen = length(data) # == 6;
       max_addtospan = datalen - windowspan # == 2
       addtospan = 0:max_addtospan

       the result contains three means
           mean(data[1+0:windowspan+0])
           mean(data[1+1:windowspan+1])
           mean(data[1+2:windowspan+2])

       result = map(i->fn(data[1+i:windowspan+i]), addtospan)
=#

function basic_roll(data::D, windowspan::Integer, fn::Function) where {N,T,D<:Union{Vector{T},NTuple{N,T}}}
    nwindows = 0:nrows(data)-windowspan
    map(i->fn(data[1+i:windowspan+i]), nwindows)
end

function basic_roll(data::D, windowspan::Integer, fn::Function, result) where {N,T,D<:Union{Vector{T},NTuple{N,T}}}
    wspan = windowspan-1
    nwindows = 1:nrows(data)-windowspan+1
    for i in nwindows
        result[i] = fn(data[i:wspan+i])
    end
    result
end

function basic_roll(data::T, windowspan::Integer, fn::Function) where {T<:AbstractArray}
    nwindows = 0:nrows(data)-windowspan
    ncolumns = ncols(data)
    map(i->fn(data[1+i:windowspan+i,1:ncolumns]), nwindows)
end

function basic_roll(data::T, windowspan::Integer, fn::Function) where {T<:AbstractArray}
    hcat(map(c->basic_roll(data2[:,c], windowspan, fn), 1:ncols(data2))...)
end

# result = (similar(ans) .= 0.0)
function basic_roll!(data::T, windowspan::Integer, fn::Function, result) where {T<:AbstractArray}
    for c in 1:ncols(data)
        result[:,c] = basic_roll(data2[:,c], windowspan, fn)
    end
    result
end


