module R2V


struct Arc
	# Only 1d-array can be appended, so use array-of-array to store node coordinates
	# each node is an Array{Int64, 1}
	nodes::Array{Array{Int64,1}}
	# index of the node is to point the start/end
	start::Int  
	dne::Int  # end node's index
end


struct Area 
	arm::Union{Array{Arc}, Nothing}
end




