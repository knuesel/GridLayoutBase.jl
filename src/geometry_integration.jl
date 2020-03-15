left(rect::HyperRectangle{2}) = minimum(rect)[1]
right(rect::HyperRectangle{2}) = maximum(rect)[1]

bottom(rect::HyperRectangle{2}) = minimum(rect)[2]
top(rect::HyperRectangle{2}) = maximum(rect)[2]


Base.getindex(bbox::HyperRectangle{2}, ::Left) = left(bbox)
Base.getindex(bbox::HyperRectangle{2}, ::Right) = right(bbox)
Base.getindex(bbox::HyperRectangle{2}, ::Bottom) = bottom(bbox)
Base.getindex(bbox::HyperRectangle{2}, ::Top) = top(bbox)


width(rect::HyperRectangle{2}) = right(rect) - left(rect)
height(rect::HyperRectangle{2}) = top(rect) - bottom(rect)

bottomleft(bbox::HyperRectangle{2}{T}) where T = Point2{T}(left(bbox), bottom(bbox))
topleft(bbox::HyperRectangle{2}{T}) where T = Point2{T}(left(bbox), top(bbox))
bottomright(bbox::HyperRectangle{2}{T}) where T = Point2{T}(right(bbox), bottom(bbox))
topright(bbox::HyperRectangle{2}{T}) where T = Point2{T}(right(bbox), top(bbox))

topline(bbox::BBox) = (topleft(bbox), topright(bbox))
bottomline(bbox::BBox) = (bottomleft(bbox), bottomright(bbox))
leftline(bbox::BBox) = (bottomleft(bbox), topleft(bbox))
rightline(bbox::BBox) = (bottomright(bbox), topright(bbox))


function BBox(left::Number, right::Number, bottom::Number, top::Number)
    mini = (left, bottom)
    maxi = (right, top)
    return BBox(mini, maxi .- mini)
end

function IRect2D(bbox::HyperRectangle{2})
    return HyperRectangle{2}(
        round.(Int, minimum(bbox)),
        round.(Int, widths(bbox))
    )
end

function RowCols(ncols::Int, nrows::Int)
    return RowCols(
        zeros(ncols),
        zeros(ncols),
        zeros(nrows),
        zeros(nrows)
    )
end

Base.getindex(rowcols::RowCols, ::Left) = rowcols.lefts
Base.getindex(rowcols::RowCols, ::Right) = rowcols.rights
Base.getindex(rowcols::RowCols, ::Top) = rowcols.tops
Base.getindex(rowcols::RowCols, ::Bottom) = rowcols.bottoms

"""
    eachside(f)
Calls f over all sides (Left, Right, Top, Bottom), and creates a BBox from the result of f(side)
"""
function eachside(f)
    return BBox(map(f, (Left(), Right(), Bottom(), Top()))...)
end

"""
mapsides(
       f, first::Union{HyperRectangle{2}, RowCols}, rest::Union{HyperRectangle{2}, RowCols}...
   )::BBox
Maps f over all sides of the rectangle like arguments.
e.g.
```
mapsides(BBox(left, right, bottom, top)) do side::Side, side_val::Number
    return ...
end::BBox
```
"""
function mapsides(
        f, first::Union{HyperRectangle{2}, RowCols}, rest::Union{HyperRectangle{2}, RowCols}...
    )
    return eachside() do side
        f(side, getindex.((first, rest...), (side,))...)
    end
end