module R2V

using FileIO, Images

# load image
img=load("polygon.png")

########################################
# Relationships among direcvtions 
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



# events that will be recorded 


# States
# Border
# Nonborder

########################################
# Relationships among direcvtions 
########################################


mutable struct Arc
	#=
    Only 1d-array can be appended, so use array-of-array to store vertex coordinates 
    each Vertex is an Array{Int64, 1}
    Node info is saved the same as Vertex, 
    but Node is not in the `vertices` to indicates its different feature as start/end point`
    =# 

    vertices::Array{Array{Int64,1}}

    start::Union{Array{Int64, 1}, Nothing} # start Node (represented by its position coordinates). 
    dne::Union{Array{Int64, 1}, Nothing}  # end Node's coordinates if any

    #linkArc::Union{Nothing, Arc}
    # Whenever change an Arc, change its linkArc's linkArc, its corsp Area's arm (self-pointer)
    linkArc::Union{Nothing, Tuple{Array{Int64, 1}, Symbol}}    # Symbol is currentDir

    linkArea::Int64

end


mutable struct Area 
	color::UnionAll
	arm::Array{Tuple{Array{Int64, 1}, Symbol}, 1}
    
end


area_count=0
area_list=Dic{Int, Area}()

arc_count=0
arc_list=Dirc{Tuple{Array{Int64, 1}, Symbol}, Arc}()
#arc_list=Dict{Array{Int64, 1}, Arc}()
# CAN NOT use position alone as key. not unique.




function node_complete(arc::T, cnnarc::T, area::T2, cnnarea::T2, arc_list::Dict, area_list::Dict) where {T<:Tuple{Array{Int64, 1}, Symbol}, T2<:Int64}
    append!(arc_list[cnnarc].vertices, reverse(arc_list[arc].vertices))
    arc_list[cnnarc].dne = arc_list[arc].start # end node 
    #TODO:write(arc_list[cnnarc], "completed_arc.csv")
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

function node_incomplete(node_Arc::T, link_arc::T, area::T2, cnnarea::T2, arc_list::Dict, arc_area::Dict) where {T<:Tuple{Array{Int64, 1}, Symbol}, T2<:Int64}
    
    #TODO

end


# Given a 2x2 pixel block `pb`, its position is [c_row, c_colum]
flag2 = pb[4] == pb[2]; flag3 = pb[4] == pb[3]
if !flag2 && !flag3
    # create node and create 2 arcs,
    # create a new area
elseif flag2 && flag3
    if  pb[1] != pb[2]
        #   -
        #  --
        if haskey(arc_list, ([c_row, c_colum-1], :DirR)) \xor haskey(arc_list, ([c_row, c_colum-1], :DirDR))
            arc=haskey(arc_list, ([c_row, c_colum-1], :DirR)) ? ([c_row, c_colum-1], :DirR); ([c_row, c_colum-1], :DirDR) 

            push!(arc_list[arc].vertices, [c_row, c_row])
            #arc_list[arc].currentDir = :DirRU

        end
        
        area=arc_list[arc].linkArea

        # check with "down" dir at [c_row-1, c_column] for connection
        if haskey(arc_list, ([c_row-1, c_column], :DirD)) \xor haskey(arc_list, ([c_row-1, c_column], :DirRD))
            cnnarc = haskey(arc_list, ([c_row-1, c_column], :DirD)) ? ([c_row-1, c_column], :DirD); ([c_row-1, c_column], :DirRD)
            cnnarea = arc_list[cnnarc].linkArea

            if arc_list[arc].linkArc != nothing
                if arc_list[cnnarc].linkArc != nothing
                    ## linked complete
                    if arc_list[cnnarc].linkArc == arc && arc_list[arc].linkArc == cnnarc
                        link_complete(arc, cnnarc, area, cnnarea, arc_list, area_list)
                    else
                else 
                    # cnnarc has start node
                    ## linked incomplete  (one arc with link, one arc with node)
                    node_incomplete(node_arc, link_arc, arc_list, arc_area)
                end
            else
                if arc_list[cnnarc].linkArc != nothing
                    # arc has start node
                    ## linked incomplete  (one arc with link, one arc with node)
                    node_incomplete(node_Arc, link_arc, arc_list, arc_area)
                else
                    ## node complete
                    node_complete(arc, cnnarc, area, cnnarea, arc_list, area_list) 
                end
            end


    end
elseif flag2 && !flag3
    if  pb[1] == pb[3]
        #   --
        #   **  
        arc_list[[c_row, c_colum]] = arc_list[[c_row, c_colum-1]]
        pop!(arc_list, [c_row, c_colum-1])
    elseif pb[1] == pb[2]
        #   -
        #   --
    else
        #   #*
        #   --
        # 
    end
elseif !flag2 && flag3
    if  pb[1] == pb[2]
        #   -*
        #   -* 
        arc_list[[c_row, c_colum]] =  arc_list[[c_row-1, c_colum]]
        pop!(arc_list, [c_row-1, c_colum])
    elseif pb[1] == pb[3]
        #   --
        #    -
    else
        #   #-
        #   *-
    end

end

