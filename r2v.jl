module R2V

using FileIO, Images

# load image
img=load("polygon.png")

####################
# Special Cases 
###################

# 2x2 pixels index order:
# 1,2
# 3,4

# events that will be recorded 

##################
# Special Cases 
###################



struct Arc
	# Only 1d-array can be appended, so use array-of-array to store vertex coordinates
	# each vertex is an Array{Int64, 1}
	vertices::Array{Array{Int64,1}}
	start::Union{Int, Nothing} # index of the vetex (as start node)
	dne::Union{Int, Nothing}  # end node's index
	linkArc::Union{Nothing, Arc}
end


struct Area 
	color::UnionAll
	arm::Union{Array{Arc}, Nothing}
end


area_count=0
area_list=Dic{Int, Area}()

arc_count=0
arc_list=Dict{Int, Arc}()


# Create a new area to the area list
if true #Fill this part      *=   or  **  or   =*   or   +*
		#                 3  *-   3   =-  3    *-   4    =-
	arc_count =+1
	arc_list[arc_count] = Arc([[c_row,c_colum]], 1, nothing, nothing)
	area_count += 1
	area_list[area_count]=Area( :color_TODO, [arc_list[arc_count]] )
elseif true # File this part     -*
			#				  2  *-
	# rige-form creates 2 arms and link them to each other
	arc_list[arc_count=+1] = Arc([[c_row,c_colum]], nothing, nothing, arc_count+1)
	arc_list[arc_count=+1] = Arc([[c_row,c_colum]], nothing, nothing, arc_count-1)
	area_list[area_count+=1]=Area( :color_TODO, [arc_list[arc_count-1], arc_list[arc_count]] )
end
#end -> elseif

# Create a new arc 
if true #TODO-fill this      *=   or  *-   
		#				  3  --   3   =-
	#TODO
end 
#end -> elseif

# Add vertex 
if true #TODO-fill this      --   or  --   or  -*   or  *-
	    #				  2  *-   2   -*   2   --   2   --
	#TODO
end
 
