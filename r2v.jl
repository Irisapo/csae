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

#
#DIR1 = Dir([2, 4, 3], [:DIR2, :DIR3])
#DIR2 = Dir([4, 3, 1], [:DIR1, :DIR4])
#DIR3 = Dir([1, 2, 4], [:DIR1, :DIR4])
#DIR4 = Dir([3, 1, 2], [:DIR2, :DIR3])
#


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
            # linked complete
            if arc_list[cnnarc].linkArc == arc && arc_list[arc].linkArc == cnnarc
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

            # node complete
            if arc_list[arc].start != nothing && arc_list[cnnarc].start != nothing
                append!(arc_list[cnnarc].vertices, reverse(arc_list[arc].vertices))
                arc_list[cnnarc].dne = arc_list[arc].start # end node 
                #TODO:write(arc_list[cnnarc], "completed_arc.csv")
                pop!(arc_list, arc);  pop!(arc_list, cnnarc)

                if length(area_list[area].arm) == 0:
                    #TODO:write(area_list[area], "completed_area.csv")
                    pop!(area_list, area)
                end
                #TODO: But need to check if this area still exists first 
                if length(area_list[cnnarea].arm) == 0:
                    #TODO:write(area_list[cnnarea], "completed_area.csv")
                    pop!(area_list, cnnarea)
                end
 
            end

            # linked incomplete

            # node incomplete
        end
            
            # Update Arc key
            #arc_list[[c_row, c_colum]] = arc_list[[c_row, c_colum-1]]
            #pop!(arc_list, [c_row, c_colum-1])

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

o
# Create a new area to the area list
if true #Fill this part      *=   or  **  or   =*   or   +*
        #                 3  *-   3   =-  3?   *-   4    =-
	# rige-form creates 2 arms and link them to each other
end

# Create a new arc 
if true #TODO-fill this      -=   or  -*   
        #                 3  **   3   =*
end 
#end -> elseif

# Add vertex 
if true #TODO-fill this      --   or  --   or  -*   or  *-
     #                    2  *-   2   -*   2   --   2   --
end
 
