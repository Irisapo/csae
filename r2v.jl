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
DirRD = Dir("down", [:DirDR])



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

    linkArc::Union{Nothing, Arc}
    # TODO:Need to change how linkArc is stored!!!!

    currentDir::Symbol

	#color::UnionAll  # color + end/start position coordinates to find next vertex
    # Don't think color is necessary...
end


mutable struct Area 
	color::UnionAll
	arm::Array{Arc}

    
end


area_count=0
area_list=Dic{Int, Area}()

arc_count=0
arc_list=Dict{Array{Int64, 1}, Arc}()
# ^ Use current position of the Arc dangle point as Dictionary key
# TODO: CAN NOT use position along as key. not unique.


# Given a 2x2 pixel block `pb`, its position is [c_row, c_colum]
flag2 = pb[4] == pb[2]; flag3 = pb[4] == pb[3]
if !flag2 && !flag3
    # create node and create 2 arcs,
    # create a new area
elseif flag2 && flag3
    if  pb[1] != pb[2]
        #   -
        #  --
        if arc_list[[c_row, c_colum-1]].currentDir == :DirR || arc_list[[c_row, c_colum-1]].currentDir == :DirDR
            push!(arc_list[[c_row, c_colum-1]].vertices, [c_row, c_row])
            arc_list[[c_row, c_colum-1]].currentDir = :DirRU

            arc_list[[c_row, c_colum]] = arc_list[[c_row, c_colum-1]]
            pop!(arc_list, [c_row, c_colum-1])
        end

        # check with "down" dir at [c_row-1, c_column] for connection
        if arc_list[[c_row-1, c_column]].currentDir =+ :DirD || arc_list[[c_row-1, c_column]].currentDir == :DirRD
            #
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

# Create a new area to the area list
if true #Fill this part      *=   or  **  or   =*   or   +*
        #                 3  *-   3   =-  3?   *-   4    =-
	arc_count =+1
	arc_list[arc_count] = Arc([[c_row,c_colum]], 1, nothing, nothing)
	area_count += 1
	area_list[area_count]=Area( :color_TODO, [arc_list[arc_count]] )
elseif true # File this part     -*
            #                 2  *-
	# rige-form creates 2 arms and link them to each other
	arc_list[arc_count=+1] = Arc([[c_row,c_colum]], nothing, nothing, arc_count+1)
	arc_list[arc_count=+1] = Arc([[c_row,c_colum]], nothing, nothing, arc_count-1)
	area_list[area_count+=1]=Area( :color_TODO, [arc_list[arc_count-1], arc_list[arc_count]] )
end
#end -> elseif

# Create a new arc 
if true #TODO-fill this      -=   or  -*   
        #                 3  **   3   =*
	#TODO
end 
#end -> elseif

# Add vertex 
if true #TODO-fill this      --   or  --   or  -*   or  *-
     #                    2  *-   2   -*   2   --   2   --
	#TODO
end
 
