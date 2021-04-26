module R2V

using FileIO, Images

# load image
img=load("polygon.png")

########################################
# Relationships among directions 
########################################

# 2x2 pixels index order:
# 1,3
# 2,4

struct Dir
    dir::Union{Array{Int8, 1}, String}
    next::Array{Symbol}

    Dir(dir) = error("Need to provide Symbols of next possible directions.")
    Dir(dir, next) = new(dir, next)
end

DirR = Dir("right", [:DirRD, :DirRU])
DirD = Dir("down", [:DirDR, :DirD])
DirDR = Dir("right", [:DirRU, :DirRD, :DirR])
DirRU = Dir("up", [:END])
DirRD = Dir("down", [:DirDR, :DirD])

########################################
# Relationships among directions 
########################################

#TODO: vertex coordinate should be in tuple instead of array!!

mutable struct Arc
    #= Only 1d-array can be appended, so use array-of-array to store vertex coordinates 
    each Vertex is an Array{Int64, 1}
    Node info is saved the same as Vertex, 
    but Node is not in the `vertices` to indicates its different feature as start/end point =# 

    vertices::Array{Tuple{Int64,Int64}}

    start::Union{Tuple{Int64, Int64}, Nothing} # start Node (represented by its position coordinates). 
    dne::Union{Tuple{Int64, Int64}, Nothing}  # end Node's coordinates if any

    # Whenever changing an Arc, change its linkArc's linkArc, its corsp Area's arm (self-pointer)
    linkArc::Union{Nothing, Tuple{Tuple{Int64, Int64}, Symbol}}    # Symbol is currentDir

    linkArea::Int64
end

mutable struct Area 
	color::UnionAll
	arm::Array{Tuple{Array{Int64, 1}, Symbol}, 1}
end


##############
#
write_vertex(io::IO, vec::Tuple{Int64, Int64}, csep=' ') = print(io, vec[1], csep, vec[2])

function write_arc(arc_file::AbstractString, arc::Arc, sep=",", subsep=" ") 
    open(arc_file, "a+") do io
        pb = PipeBuffer()

        if arc.start != nothing
            write_vertex(pb, arc.start, subsep)
            print(pb, sep)
        end

        lastr = last(axes(arc.vertices, 1))
        for i = axes(arc.vertices, 1)
            write_vertex(pb, arc.vertices[i], subsep)
            if i != lastr
                print(pb, sep)
            else
                arc.dne == nothing ? print(pb, "\n") : (print(pb, sep); write_vertex(pb, arc.dne, subsep); print(pb, "\n") )
            end 
        end

        write(io, take!(pb))
    end
        
end


#
##############
area_count=0
area_list=Dic{Int, Area}()

arc_list=Dirc{Tuple{Array{Int64, 1}, Symbol}, Arc}()
# CAN NOT use position alone as key. not unique.

function node_complete(arc::T, cnnarc::T, area::T2, cnnarea::T2, arc_list::Dict, area_list::Dict) where {T<:Tuple{Array{Int64, 1}, Symbol}, T2<:Int64}
    append!(arc_list[cnnarc].vertices, reverse(arc_list[arc].vertices))
    arc_list[cnnarc].dne = arc_list[arc].start # end node 
    #TODO:write(arc_list[cnnarc], "completed_arc.csv")
    write(completed_arc, arc_list[cnnarc])

    pop!(arc_list, arc)
    pop!(arc_list, cnnarc)

    if length(area_list[area].arm) == 0
        #TODO:write(area_list[area], "completed_area.csv")
        pop!(area_list, area)
    end
    #TODO: But need to check if this area still exists first 
    if length(area_list[cnnarea].arm) == 0
        #TODO:write(area_list[cnnarea], "completed_area.csv")
        pop!(area_list, cnnarea)
    end

end

function link_complete(arc::T, cnnarc::T, area::T2, cnnarea::T2, arc_list::Dict, area_list::Dict) where {T<:Tuple{Array{Int64, 1}, Symbol}, T2<:Int64}
    pop!(area_list[area].arm, area);  pop!(area_list[cnnarea].arm, cnnarea)
    if length(area_list[area].arm) == 0:
        #TODO:write(area_list[area], "completed_area.csv")
        pop!(area_list, area)
    end
    #TODO: But need to check if this area still exists first 
    if length(area_list[cnnarea].arm) == 0:
        #TODO:write(area_list[cnnarea], "completed_area.csv")
        pop!(area_list, cnnarea)
    end
    
    append!(arc_list[cnnarc].vertices, reverse(arc_list[arc].vertices))
    #TODO:write(arc_list[cnnarc], "completed_arc.csv")
    pop!(arc_list, arc);  pop!(arc_list, cnnarc)

end

function node_incomplete(node_arc::T, link_arc::T, node_area::T2, link_area::T2, arc_list::Dict, arc_area::Dict) where {T<:Tuple{Array{Int64, 1}, Symbol}, T2<:Int64}
    
    cnn2arc = arc_list[link_arc].linkArc
    # cnn2area = arc_list[cnn2arc].area # # should be the same as `link_area`
    @assert arc_list[cnn2arc].linkArea == link_area


    # flip link_arc
    reverse!(arc_list[link_arc].vertices)
    append!(arc_list[link_arc].vertices, arc_list[cnn2arc].vertices)
    pop!(arc_list, cnn2arc)

    # connect 
    append!(arc_list[node_arc].vertices, arc_list[link_arc].vertices)
    pop!(arc_list, link_arc)
    
    pop!(area_list[cnn2area].arm, cnn2arc)
    pop!(area_list[link_area].arm, link_arc)
    
    # merge areas if necessary
    if link_area != node_area
        for arm in area_list[link_area].arm
            arc_list[arm].linkArea = node_area
        end
    end      
   
end


function node_complete(arc::T, cnnarc::T, area::T2, cnnarea::T2, arc_list::Dict, area_list::Dict) where {T<:Tuple{Array{Int64, 1}, Symbol}, T2<:Int64}
    
    append!(arc_list[cnnarc].vertices, reverse(arc_list[arc].vertices))
    arc_list[cnnarc].dne = arc_list[arc].start

    pop!(arc_list, arc)
    pop!(area_list[area].arm, arc)

    #TODO write(arc_list[cnnarc], "complete_arc.csv")
    pop!(arc_list, cnnarc)
    pop!(area_list[cnnarea].arm, cnnarc)

    if length(area_list[area].arm) == 0
        #TODO write(area_list[area], "complete_area.csv")
        pop!(area_list, area)
    end
    if length(area_list[cnnarea].arm) == 0
        # TODO write(area_list[cnnarea], "complete_area.csv")
        pop!(area_liat, cnnarea)
    end

end

function arc_connect(arc::T, cnnarc::T, area::T2, cnnarea::T2, arc_list::Dict, area_list::Dict) where {T<:Tuple{Array{Int64, 1}, Symbol}, T2<:Int64}

    if arc_list[arc].linkArc != nothing
        if arc_list[cnnarc].linkArc != nothing
            ## linked complete
            if arc_list[cnnarc].linkArc == arc && arc_list[arc].linkArc == cnnarc
                link_complete(arc, cnnarc, area, cnnarea, arc_list, area_list)
            end
        else 
            # cnnarc has start node
            ## linked incomplete  (one arc with link, one arc with node)
            node_incomplete(cnnarc, arc, cnnarea, area, arc_list, arc_area)
        end
    else
        if arc_list[cnnarc].linkArc != nothing
            # arc has start node
            ## linked incomplete  (one arc with link, one arc with node)
            node_incomplete(arc, cnnarc, area, cnnarea, arc_list, arc_area)
        else
            ## node complete
            node_complete(arc, cnnarc, area, cnnarea, arc_list, area_list) 
        end
    end
end


function node_end(node::Array{Int64, 1}, arc::Tuple{Array{Int64, 1}, Symbol}, area::Int64, arc_list::Dict, area_list::Dict)

    arc_list[arc].dne = node 
    #TODO: write(arc_list[arc], "complete_arc.csv")
    pop!(arc_list, arc)

    pop!(area_list[area].arm, arc)
    if length(area_list[area].arm) == 0
        #TODO: write(area_list[area], "compelte_area.csv")
        pop!(area_list, area)
    end
end


function link_flip(node::Array{Int64,1}, arc::Tuple{Array{Int64,1}, Symbol}, area::Int64, arc_list::Dict, area_list::Dict) 
    cnnarc = arc_list[arc].linkArc

    append!(arc_list[cnnarc].vertices, reverse(arc_list[arc].vertices))
    arc_list[cnnarc].start = node 

    pop!(arc_list, arc)
    pop!(area_list[area].arm, arc)


end

function node_connect(node::Array{Int64,1}, arc::Tuple{Array{Int64,1}, Symbol}, area::Int64, arc_list::Dict, area_list::Dict)
    # node end 
    if arc_list[arc].start != nothing

        area = arc_list[arc].linkArea
        node_end(node, arc, area, arc_list, area_list)

    elseif arc_list[arc].linkArc != nothing
    # link flip
        area = arc_list[arc].linkArea

        link_flip(node, arc, cnnarc, area, arc_list, area_list) 

    end

end


# Given a 2x2 pixel block `pb`, its position is [c_row, c_column]
flag2 = pb[4] == pb[2]: flag3 = pb[4] == pb[3]
if !flag2 && !flag3
    area_count += 1

    if pb[2] == pb[1] == pb[3]
    # --
    # -
    # create 2 linked arcs 
    # create a new area

        arc_list[([c_row, c_column], :DirR)] = Arc([[c_row, c_column]], nothing, nothing, ([c_row, c_column], :DirD), area_count)
        arc_list[([c_row, c_column], :DirD)] = Arc([[c_row, c_column]], nothing, nothing, ([c_row, c_column], :DirR), area_count)
        area_list[area_count] = Area(pb[4], [([c_row, c_column], :DirR), ([c_row, c_column], :DirD)])

        # connect arc if necessary
        if haskey(arc_list, ([c_row-1, c_column+1], :DirD)) \xor haskey(arc_list, ([c_row-1, c_column+1], :DirRD))
            cnnarc = haskey(arc_list, ([c_row-1, c_column+1], :DirD)) ? ([c_row-1, c_column+1], :DirD) : ([c_row-1, c_column+1], :DirRD)
            cnnarea = arc_list[cnnarc].linkArea

            arc = ([c_row, c_column], :DirR)
            area = area_count

            arc_connect(arc, cnnarc, area, cnnarea, arc_list, area_list) 
        end

    else
    # create node and create 2 arcs,
    # create a new area
        arc_list[([c_row, c_column], :DirR)] = Arc([], [c_row, c_column], nothing,  area_count)
        arc_list[([c_row, c_column], :DirD)] = Arc([], [c_row, c_column], nothing,  area_count)
        area_list[area_count] = Area(pb[4], [([c_row, c_column], :DirR), ([c_row, c_column], :DirD)])

        map((([c_row-1, c_column+1], :DirD), ([c_row-1, c_column+1], :DirRD),([c_row, c_column-1], :DirR),([c_row, c_column-1], :DirDR))) do arc
            if haskey(arc_list, arc)
                
                area = arc_list[arc].linkArea
                node_connect([c_row, c_column], arc, area, arc_list, area_list)
           end
        end

    end

    # connect arc w/ arc_list[([c_row, c_column], :DirR)] if necessary
    @assert !haskey(arc_list, ([c_row-1, c_column+1], :DirD)) || !haskey(arc_list, ([c_row-1, c_column+1], :DirRD))
    arc = ([c_row, c_column], :DirR)
    area = area_count
    map((([c_row-1, c_column+1], :DirD), ([c_row-1, c_column+1], :DirRD), nothing)) do cnnarc
            if haskey(arc_list, cnnarc)
                cnnarea = arc_list[cnnarc].linkArc
                arc_connect(arc, cnnarc, area, cnnarea, arc_list, area_list) 
            end
    end

    

elseif flag2 && flag3
    if  pb[1] != pb[2]
        #   -
        #  --
        if haskey(arc_list, ([c_row, c_column-1], :DirR)) \xor haskey(arc_list, ([c_row, c_column-1], :DirDR))
            arc=haskey(arc_list, ([c_row, c_column-1], :DirR)) ? ([c_row, c_column-1], :DirR): ([c_row, c_column-1], :DirDR) 

            push!(arc_list[arc].vertices, [c_row, c_row])


            # check with "down" dir at [c_row-1, c_column] for connection
            # Must Have An Arc To Connect
            @assert haskey(arc_list, ([c_row-1, c_column], :DirD)) \xor haskey(arc_list, ([c_row-1, c_column], :DirRD))
            cnnarc = haskey(arc_list, ([c_row-1, c_column], :DirD)) ? ([c_row-1, c_column], :DirD): ([c_row-1, c_column], :DirRD)
            cnnarea = arc_list[cnnarc].linkArea

            area=arc_list[arc].linkArea


            arc_connect(arc, cnnarc, area, cnnarea, arc_list, area_list) 
           
        end

    end

elseif flag2 && !flag3
    if  pb[1] == pb[3]
        #   --
        #   **  
        @assert haskey(arc_list, ([c_row, c_column-1],:DirR)) \xor haskey(arc_list, ([c_row, c_column-1],:DirDR))
        arc = haskey(arc_list, ([c_row, c_column-1],:DirR)) ? ([c_row, c_column-1],:DirR): ([c_row, c_column-1],:DirDR)
        push!(arc_list[arc].vertices, [c_row, c_column])


        # connect w/ down at [c_row-1, c_column+1] if possible
        if haskey(arc_list, ([c_row-1, c_column+1], :DirD)) \xor haskey(arc_list, ([c_row-1, c_column+1], :DirRD))
            cnnarc = haskey(arc_list, ([c_row-1, c_column+1], :DirD)) ? ([c_row-1, c_column+1], :DirD): ([c_row-1, c_column+1], :DirRD)
            cnnarea = arc_list[cnnarc].linkArea

            area = arc_list[arc].linkArea
            
            # connect scenarios
            arc_connect(arc, cnnarc, area, cnnarea, arc_list, area_list)
        
        else
        # update arc key
            arc_list[([c_row, c_column],:DirR)] = arc_list[arc]
            pop!(arc_list, arc)
        end

    elseif pb[1] == pb[2]
        #   -
        #   --
        @assert haskey(arc_list, ([c_row-1, c_column],:DirD)) \xor haskey(arc_list, ([c_row-1, c_column],:DirRD))
        arc = haskey(arc_list, ([c_row-1, c_column],:DirD))? ([c_row-1, c_column],:DirD): ([c_row-1, c_column],:DirRD)
        push!(arc_list[arc].vertices, [c_row, c_column])

        # conect w/ down at [c_row-1, c_column+1] if possible
        if haskey(arc_list, ([c_row-1, c_column+1], :DirD)) \xor haskey(arc_list, ([c_row-1, c_column+1], :DirRD))
            cnnarc = haskey(arc_list, ([c_row-1, c_column+1], :DirD)) ? ([c_row-1, c_column+1], :DirD): ([c_row-1, c_column+1], :DirRD)
            cnnarea = arc_list[cnnarc].linkArea

            area = arc_list[arc].linkArea

            # connect scenarios
            arc_connect(arc, cnnarc, area, cnnarea, arc_list, area_list)

        else
        # update arc
            arc_list[([c_row, c_column],:DirR)] = arc_list[arc]
            pop!(arc_list, arc)
        end

    else
        #   #*
        #   --
        @assert haskey(arc_list, ([c_row-1, c_column], :DirD)) \xor haskey(arc_list, ([c_row-1, c_column], :DirRD))
        areaarc = haskey(arc_list, ([c_row-1, c_column], :DirD)) ? ([c_row-1, c_column], :DirD): ([c_row-1, c_column], :DirRD)
        area = arc_list[areaarc].linkArea
        # create new arc
        arc_list[([c_row, c_column], :DirR)] = Arc([], [c_row, c_column], nothing,  area)         
        push!(area_list[area].arm, ([c_row, c_column], :DirR))

        # connect w/ arcs if necessary 
        map((([c_row-1, c_column], :DirD), ([c_row-1, c_column], :DirRD), ([c_row, c_column-1], :DirR), ([c_row-1, c_column], :DirDR))) do arc
            if haskey(arc_list, arc) 

                area = arc_list[arc].linkArea
                node_connect([c_row, c_column], arc, area, arc_list, area_list)
            end
        end


    end
elseif !flag2 && flag3
    if  pb[1] == pb[2]
        #   -*
        #   -* 
        @assert haskey(arc_list, ([c_row-1, c_column], :DirD)) \xor haskey(arc_list, ([c_row-1, c_column], :DirRD))
        arc = haskey(arc_list, ([c_row-1, c_column], :DirD)) ?  ([c_row-1, c_column], :DirD): ([c_row-1, c_column], :DirRD)
        push!(arc_list[arc].vertices, [c_row, c_column])

        arc_list[([c_row, c_column], :DirD)] = arc_list[arc]
        pop!(arc_list, arc)

    end

    elseif pb[1] == pb[3]
        #   --
        #    -
        @assert haskey(arc_list, ([c_row, c_column-1], :DirR)) \xor haskey(arc_list, ([c_row, c_column-1], :DirDR))
        arc = haskey(arc_list, ([c_row, c_column-1], :DirR)) ? ([c_row, c_column-1], :DirR): ([c_row, c_column-1], :DirDR)
        push!(arc_list[arc].vertices, [c_row, c_column])

        arc_list[([c_row, c_column], :DirD)] = arc_list[arc]
        pop!(arc_list, arc)
    else
        #   #-
        #   *-
        @assert haskey(arc_list, ([c_row, c_column-1], :DirR)) \xor haskey(arc_list, ([c_row, c_column-1], :DirDR))
        areaarc = haskey(arc_list, ([c_row, c_column-1], :DirR)) ? ([c_row, c_column-1], :DirR): ([c_row, c_column-1], :DirDR)
        area = arc_list[areaarc].linkArea
        # create new arc
        arc_list[([c_row, c_column], :DirD)] = Arc([], [c_row, c_column], nothing,  area)         
        push!(area_list[area].arm, ([c_row, c_column], :DirD))

        # connect w/ arcs if necessary 
        map((([c_row-1, c_column], :DirD), ([c_row-1, c_column], :DirRD), ([c_row, c_column-1], :DirR), ([c_row-1, c_column], :DirDR))) do arc
            if haskey(arc_list, arc) 

                area = arc_list[arc].linkArea
                node_connect([c_row, c_column], arc, area, arc_list, area_list)
            end
        end


    end

end

