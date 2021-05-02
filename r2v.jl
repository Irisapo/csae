module R2V

export rr2v

import Base: pop! 

function pop!(ar::Array{Tuple{Tuple{Int64,Int64},Symbol},1}, it::Tuple{Tuple{Int64,Int64},Symbol})
    filter!(x -> x!=it, ar)
end

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

mutable struct Arc
    #= Only 1d-array can be appended, so use array-of-tuple to store vertex coordinates 
    each Vertex is an Tuple{Int64, Int64}
    Node info is saved the same way as for Vertex, 
    but Node is not in the `vertices` to indicates its different feature as start/end point =# 

    vertices::Array{Tuple{Int64,Int64}}

    start::Union{Tuple{Int64, Int64}, Nothing} # start Node (represented by its position coordinates). 
    dne::Union{Tuple{Int64, Int64}, Nothing}  # end Node's coordinates if any

    # Whenever changing an Arc, change its linkArc's linkArc, its corsp Area's arm (self-pointer)
    linkArc::Union{Nothing, Tuple{Tuple{Int64, Int64}, Symbol}}    # Symbol is currentDir

    linkArea::Int64
end

mutable struct Area 
	color
    arm::Array{Tuple{Tuple{Int64, Int64}, Symbol}}
end


##################
# Export to files 
##################
write_vertex(io::IO, vec::Tuple{Int64, Int64}, csep=' ') = print(io, vec[1], csep, vec[2])

function write_arc(arc_file::AbstractString, arc::Arc; sep=",", subsep=" ") 
    open(arc_file, "a+") do io
        pb = PipeBuffer()

        if arc.start !== nothing
            write_vertex(pb, arc.start, subsep)
            print(pb, sep)
        end

        lastr = last(axes(arc.vertices, 1))
        for i = axes(arc.vertices, 1)
            write_vertex(pb, arc.vertices[i], subsep)
            if i != lastr
                print(pb, sep)
            else
                lastr = sep
            end 
            (bytesavailable(pb) > (16*1024)) && write(io, take!(pb))  # just in case
        end

        if arc.dne === nothing
            print(pb, "\n")
        else
            lastr == sep ? (print(pb, sep); write_vertex(pb, arc.dne, subsep); print(pb, "\n")) : (write_vertex(pb, arc.dne, subsep); print(pb, "\n")) 
        end

        write(io, take!(pb))
    end
        
end


function write_area(area_file::AbstractString, area_list::Dict, area_name::Int64; sep="\n", subsep=",")
    open(area_file, "a+") do io

        pb = PipeBuffer()
        
        #print(pb, "area_name", subsep, "color", "\n")

        print(pb, string(area_name), subsep)
        print(pb, area_list[area_name].color, sep)

        write(io, take!(pb))
    end
end

##################
# Export to files 
##################



function node_complete(arc::T, cnnarc::T, area::T2, cnnarea::T2, arc_list::Dict, area_list::Dict, arc_file::AbstractString, area_file::AbstractString) where {T<:Tuple{Tuple{Int64, Int64}, Symbol}, T2<:Int64}
    reverse!(arc_list[cnnarc].vertices)
    append!(arc_list[cnnarc].vertices, arc_list[arc].vertices)
    arc_list[cnnarc].dne = arc_list[arc].start # end node 
    write_arc(arc_file, arc_list[cnnarc], sep=",", subsep=" ") 

    pop!(arc_list, arc)
    pop!(arc_list, cnnarc)

    pop!(area_list[area].arm, arc)
    pop!(area_list[cnnarea].arm, cnnarc)
    if length(area_list[area].arm) == 0
        write_area(area_file, area_list, area, sep="\n", subsep=",")
        pop!(area_list, area)
    end

#    #No need to check cnnarea b/c it is the same as area
#    #    if length(area_list[cnnarea].arm) == 0
#        write_area(area_file, area_list, cnnarea, sep="\n", subsep=",")
#        pop!(area_list, cnnarea)
#    end

end

function link_complete(arc::T, cnnarc::T, area::T2, cnnarea::T2, arc_list::Dict, area_list::Dict, arc_file::AbstractString, area_file::AbstractString) where {T<:Tuple{Tuple{Int64, Int64}, Symbol}, T2<:Int64}
    pop!(area_list[area].arm, arc);  pop!(area_list[cnnarea].arm, cnnarc)
    if length(area_list[area].arm) == 0
        write_area(area_file, area_list, area, sep="\n", subsep=",")
        pop!(area_list, area)
    end
    #No need to check cnnarea b/c it is the same as area
   
    append!(arc_list[cnnarc].vertices, reverse(arc_list[arc].vertices))
    write_arc(arc_file, arc_list[cnnarc], sep=",", subsep=" ") 
    pop!(arc_list, arc);  pop!(arc_list, cnnarc)

end

function node_incomplete(node_arc::T, link_arc::T, node_area::T2, link_area::T2, arc_list::Dict, arc_area::Dict) where {T<:Tuple{Tuple{Int64, Int64}, Symbol}, T2<:Int64}
    
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

    #Update arc-key
    arc_list[cnn2arc] = arc_list[node_arc]
    pop!(arc_list, node_arc)

    pop!(area_list[node_area].arm, node_arc)
    push!(area_list[node_area].arm, cnn2arc)
    
    # merge areas if necessary
    if link_area != node_area
        for arm in area_list[link_area].arm
            arc_list[arm].linkArea = node_area
        end
        write_area(area_file, area_list, link_area, sep="\n", subsep=",")
        pop!(area_list, link_area)
    end      
   
end


function link_incomplete(arc::T, cnnarc::T, area::T2, cnnarea::T2, arc_list::Dict, area_list::Dict, arc_file::AbstractString, area_file::AbstractString) where {T<:Tuple{Tuple{Int64, Int64}, Symbol}, T2<:Int64}
    
    push!(arc_list[cnnarc].vertices, arc_list[arc].vertices[end])

    arc_larc = arc_list[arc].linkArc
    cnnarc_larc = arc_list[cnnarc].linkArc

    # flip and merge linked-arcs each
    reverse!(arc_list[arc].vertices)
    pop!(arc_list[arc].vertices)
    append!(arc_list[arc].vertices, arc_list[arc_larc].vertices)

    reverse!(arc_list[cnnarc].vertices)
    pop!(arc_list[cnnarc].vertices)
    append!(arc_list[cnnarc].vertices, arc_list[cnnarc_larc].vertices)


    # link & remove old (linkArc)s
    arc_list[arc_larc] = arc_list[arc]
    arc_list[cnnarc_larc] = arc_list[cnnarc]
    arc_list[arc_larc].linkArc = cnnarc_larc
    arc_list[cnnarc_larc].linkArc = arc_larc
    pop!(arc_list, arc)
    pop!(arc_list, cnnarc)

    pop!(area_list[area].arm, arc)
    pop!(area_list[cnnarea].arm, cnnarc)

    # merge areas if necessary
    if area != cnnarea
        for arm in area_list[cnnarea].arm
            arc_list[arm].linkArea = area
        end
        write_area(area_file, area_list, cnnarea, sep="\n", subsep=",")
        pop!(area_list, cnnarea)
    end  

end

function arc_connect(arc::T, cnnarc::T, area::T2, cnnarea::T2, arc_list::Dict, area_list::Dict, arc_file::AbstractString, area_file::AbstractString) where {T<:Tuple{Tuple{Int64, Int64}, Symbol}, T2<:Int64}

    if arc_list[arc].linkArc !== nothing
        if arc_list[cnnarc].linkArc !== nothing
            ## linked complete
            if arc_list[cnnarc].linkArc == arc && arc_list[arc].linkArc == cnnarc
                link_complete(arc, cnnarc, area, cnnarea, arc_list, area_list, arc_file, area_file)
            else 
            ## linked incomplete
                link_incomplete(arc, cnnarc, area, cnnarea, arc_list, area_list, arc_file, area_file)
            end
        else 
            # cnnarc has start node
            ## linked incomplete  (one arc with link, one arc with node)
            node_incomplete(cnnarc, arc, cnnarea, area, arc_list, arc_area)
        end
    else
        if arc_list[cnnarc].linkArc !== nothing
            # arc has start node
            ## linked incomplete  (one arc with link, one arc with node)
            node_incomplete(arc, cnnarc, area, cnnarea, arc_list, arc_area)
        else
            ## node complete
            node_complete(arc, cnnarc, area, cnnarea, arc_list, area_list, arc_file, area_file) 
        end
    end
end


function node_end(node::Tuple{Int64, Int64}, arc::Tuple{Tuple{Int64, Int64}, Symbol}, area::Int64, arc_list::Dict, area_list::Dict, arc_file::AbstractString, area_file::AbstractString)

    arc_list[arc].dne = node 
    write_arc(arc_file, arc_list[arc], sep=",", subsep=" ") 
    pop!(arc_list, arc)

    pop!(area_list[area].arm, arc)
    if length(area_list[area].arm) == 0
        write_area(area_file, area_list, area, sep="\n", subsep=",")
        pop!(area_list, area)
    end
end


function link_flip(node::Tuple{Int64, Int64}, arc::Tuple{Tuple{Int64, Int64}, Symbol}, area::Int64, arc_list::Dict, area_list::Dict) 
    cnnarc = arc_list[arc].linkArc

    reverse!(arc_list[arc].vertices)
    pop!(arc_list[arc].vertices) # remove last vertex to avoid repetition
    append!(arc_list[arc].vertices, arc_list[cnnarc].vertices)
    arc_list[arc].start = node 
    # remove linkArc
    arc_list[arc].linkArc = nothing

    # change key & remove cnnarc
    arc_list[cnnarc] = arc_list[arc]
    pop!(arc_list, arc)
    pop!(area_list[area].arm, arc)


end

function node_connect(node::Tuple{Int64, Int64}, arc::Tuple{Tuple{Int64, Int64}, Symbol}, area::Int64, arc_list::Dict, area_list::Dict, arc_file::AbstractString, area_file::AbstractString)
    # node end 
    if arc_list[arc].start !== nothing

        area = arc_list[arc].linkArea
        node_end(node, arc, area, arc_list, area_list, arc_file, area_file)

    elseif arc_list[arc].linkArc !== nothing
    # link flip
        area = arc_list[arc].linkArea

        link_flip(node, arc, area, arc_list, area_list) 
    end

end




function handle_event(pb, c_row::Int64, c_column::Int64, area_count::Int64, arc_list::Dict, area_list::Dict, arc_file::AbstractString, area_file::AbstractString) 

    # Given a 2x2 pixel block `pb`, its position is (c_row, c_column)
    flag2 = pb[4] == pb[2]; flag3 = pb[4] == pb[3]
    if !flag2 && !flag3
        area_count += 1

        if pb[2] == pb[1] == pb[3]
        # --       # create 2 linked arcs 
        # -        # create a new area
            arc_list[((c_row, c_column), :DirR)] = Arc([(c_row, c_column)], nothing, nothing, ((c_row, c_column), :DirD), area_count)
            arc_list[((c_row, c_column), :DirD)] = Arc([(c_row, c_column)], nothing, nothing, ((c_row, c_column), :DirR), area_count)
            area_list[area_count] = Area(pb[4], [((c_row, c_column), :DirR), ((c_row, c_column), :DirD)])

            # It's not possible to connect
            # connect arc if necessary
            #if haskey(arc_list, ((c_row-1, c_column+1), :DirD)) ⊻ haskey(arc_list, ((c_row-1, c_column+1), :DirRD))
            #    cnnarc = haskey(arc_list, ((c_row-1, c_column+1), :DirD)) ? ((c_row-1, c_column+1), :DirD) : ((c_row-1, c_column+1), :DirRD)
            #    cnnarea = arc_list[cnnarc].linkArea

            #    arc = ((c_row, c_column), :DirR)
            #    area = area_count
            #    arc_connect(arc, cnnarc, area, cnnarea, arc_list, area_list, arc_file, area_file) 
            #end

        else
        # create node and create 2 arcs,
        # create a new area
            arc_list[((c_row, c_column), :DirR)] = Arc([], (c_row, c_column), nothing,  nothing, area_count)
            arc_list[((c_row, c_column), :DirD)] = Arc([], (c_row, c_column), nothing,  nothing, area_count)
            area_list[area_count] = Area(pb[4], [((c_row, c_column), :DirR), ((c_row, c_column), :DirD)])

            map((((c_row-1, c_column), :DirD), ((c_row-1, c_column), :DirRD),((c_row, c_column-1), :DirR),((c_row, c_column-1), :DirDR))) do arc
                if haskey(arc_list, arc)
                    
                    area = arc_list[arc].linkArea
                    node_connect((c_row, c_column), arc, area, arc_list, area_list, arc_file, area_file)
               end
            end

        end

        # It's not possible to connect
        # connect arc w/ arc_list[((c_row, c_column), :DirR)] if necessary
        # @assert !haskey(arc_list, ((c_row-1, c_column+1), :DirD)) || !haskey(arc_list, ((c_row-1, c_column+1), :DirRD))
        # arc = ((c_row, c_column), :DirR)
        # area = area_count
        # map((((c_row-1, c_column+1), :DirD), ((c_row-1, c_column+1), :DirRD), nothing)) do cnnarc
        #         if haskey(arc_list, cnnarc)
        #             cnnarea = arc_list[cnnarc].linkArc
        #             arc_connect(arc, cnnarc, area, cnnarea, arc_list, area_list, arc_file, area_file) 
        #         end
        # end

        

    elseif flag2 && flag3
        if  pb[1] != pb[2]
            #   -
            #  --
            if haskey(arc_list, ((c_row, c_column-1), :DirR)) ⊻ haskey(arc_list, ((c_row, c_column-1), :DirDR))
                haskey(arc_list, ((c_row, c_column-1), :DirR)) ? arc=((c_row, c_column-1), :DirR) : arc=((c_row, c_column-1), :DirDR) 

                push!(arc_list[arc].vertices, (c_row, c_column))


                # check with "down" dir at (c_row-1, c_column) for connection
                # Must Have An Arc To Connect
                @assert haskey(arc_list, ((c_row-1, c_column), :DirD)) ⊻ haskey(arc_list, ((c_row-1, c_column), :DirRD))
                haskey(arc_list, ((c_row-1, c_column), :DirD)) ? cnnarc=((c_row-1, c_column), :DirD) : cnnarc=((c_row-1, c_column), :DirRD)
                cnnarea = arc_list[cnnarc].linkArea

                area=arc_list[arc].linkArea


                arc_connect(arc, cnnarc, area, cnnarea, arc_list, area_list, arc_file, area_file) 
               
            end

        end

    elseif flag2 && !flag3
        if  pb[1] == pb[3]
            #   --
            #   **  
            @assert haskey(arc_list, ((c_row, c_column-1),:DirR)) ⊻ haskey(arc_list, ((c_row, c_column-1),:DirDR))
            arc = haskey(arc_list, ((c_row, c_column-1),:DirR)) ? ((c_row, c_column-1),:DirR) : ((c_row, c_column-1),:DirDR)

            # It's not possible to connect
            # connect w/ down at (c_row-1, c_column+1) if possible
            # if haskey(arc_list, ((c_row-1, c_column+1), :DirD)) ⊻ haskey(arc_list, ((c_row-1, c_column+1), :DirRD))
            #     haskey(arc_list, ((c_row-1, c_column+1), :DirD)) ? cnnarc=((c_row-1, c_column+1), :DirD) : cnnarc=((c_row-1, c_column+1), :DirRD)
            #     cnnarea = arc_list[cnnarc].linkArea
            #     area = arc_list[arc].linkArea
            #     
            #     # connect scenarios
            #     arc_connect(arc, cnnarc, area, cnnarea, arc_list, area_list, arc_file, area_file)
            # end

            # update arc key
            ## linkArc's linkArc (self)
            if arc_list[arc].linkArc !== nothing
                cnnarc = arc_list[arc].linkArc
                arc_list[cnnarc].linkArc = ((c_row, c_column), :DirR)
            end
            ## linkArea's arm
            area = arc_list[arc].linkArea
            pop!(area_list[area].arm, arc)
            push!(area_list[area].arm, ((c_row, c_column), :DirR))
            ## key
            arc_list[((c_row, c_column),:DirR)] = arc_list[arc]
            pop!(arc_list, arc)


        elseif pb[1] == pb[2]
            #   -
            #   --
            @assert haskey(arc_list, ((c_row-1, c_column),:DirD)) ⊻ haskey(arc_list, ((c_row-1, c_column),:DirRD))  (println(c_row,"-", c_column);keys(arc_list) )
            haskey(arc_list, ((c_row-1, c_column),:DirD)) ? arc=((c_row-1, c_column),:DirD) : arc=((c_row-1, c_column),:DirRD)
            push!(arc_list[arc].vertices, (c_row, c_column))

            # It's not possible to connect
            # conect w/ down at (c_row-1, c_column+1) if possible
            #if haskey(arc_list, ((c_row-1, c_column+1), :DirD)) ⊻ haskey(arc_list, ((c_row-1, c_column+1), :DirRD))
            #    haskey(arc_list, ((c_row-1, c_column+1), :DirD)) ? cnnarc=((c_row-1, c_column+1), :DirD) : cnnarc=((c_row-1, c_column+1), :DirRD)
            #    cnnarea = arc_list[cnnarc].linkArea

            #    area = arc_list[arc].linkArea

            #    # connect scenarios
            #    arc_connect(arc, cnnarc, area, cnnarea, arc_list, area_list, arc_file, area_file)
            #end

            # update arc key
            ## linkArc's linkArc (self)
            if arc_list[arc].linkArc !== nothing
                cnnarc = arc_list[arc].linkArc
                arc_list[cnnarc].linkArc = ((c_row, c_column), :DirR)
            end 
            ## linkArea's arm
            area = arc_list[arc].linkArea
            pop!(area_list[area].arm, arc)
            push!(area_list[area].arm, ((c_row, c_column), :DirR))
            ## key
            arc_list[((c_row, c_column),:DirR)] = arc_list[arc]
            pop!(arc_list, arc)

        else
            #   #*
            #   --
            @assert haskey(arc_list, ((c_row-1, c_column), :DirD)) ⊻ haskey(arc_list, ((c_row-1, c_column), :DirRD))
            haskey(arc_list, ((c_row-1, c_column), :DirD)) ? areaarc=((c_row-1, c_column), :DirD) : areaarc=((c_row-1, c_column), :DirRD)
            area = arc_list[areaarc].linkArea
            # create new arc
            arc_list[((c_row, c_column), :DirR)] = Arc([], (c_row, c_column), nothing, nothing, area) 
            push!(area_list[area].arm, ((c_row, c_column), :DirR))

            # connect w/ arcs if necessary 
            map((((c_row-1, c_column), :DirD), ((c_row-1, c_column), :DirRD), ((c_row, c_column-1), :DirR), ((c_row-1, c_column), :DirDR))) do arc
                if haskey(arc_list, arc) 

                    area = arc_list[arc].linkArea
                    node_connect((c_row, c_column), arc, area, arc_list, area_list, arc_file, area_file)
                end
            end


        end
    elseif !flag2 && flag3
        if  pb[1] == pb[2]
            #   -*
            #   -* 
            @assert haskey(arc_list, ((c_row-1, c_column), :DirD)) ⊻ haskey(arc_list, ((c_row-1, c_column), :DirRD))
            haskey(arc_list, ((c_row-1, c_column), :DirD)) ?  arc=((c_row-1, c_column), :DirD) : arc=((c_row-1, c_column), :DirRD)

            area = arc_list[arc].linkArea

            # update arc-key
            ## linkArc's linkArc (self)
            if arc_list[arc].linkArc !== nothing
                cnnarc = arc_list[arc].linkArc
                arc_list[cnnarc].linkArc = ((c_row, c_column), :DirD)
            end 
            ## linkArea's arm
            area = arc_list[arc].linkArea
            pop!(area_list[area].arm, arc)
            push!(area_list[area].arm, ((c_row, c_column), :DirD))
            ## key
            arc_list[((c_row, c_column), :DirD)] = arc_list[arc]
            pop!(arc_list, arc)

            pop!(area_list[area].arm, arc)
            push!(area_list[area].arm,((c_row, c_column), :DirD))


        elseif pb[1] == pb[3]
            #   --
            #    -
            @assert haskey(arc_list, ((c_row, c_column-1), :DirR)) ⊻ haskey(arc_list, ((c_row, c_column-1), :DirDR))
            arc = haskey(arc_list, ((c_row, c_column-1), :DirR)) ? ((c_row, c_column-1), :DirR) : ((c_row, c_column-1), :DirDR)
            push!(arc_list[arc].vertices, (c_row, c_column))

            # update arc-key
            ## linkArc's linkArc (self)
            if arc_list[arc].linkArc !== nothing
                cnnarc = arc_list[arc].linkArc
                arc_list[cnnarc].linkArc = ((c_row, c_column), :DirD)
            end
            ## linkArea's arm
            area = arc_list[arc].linkArea
            pop!(area_list[area].arm, arc)
            push!(area_list[area].arm, ((c_row, c_column), :DirD))
            ## key
            arc_list[((c_row, c_column), :DirD)] = arc_list[arc]
            pop!(arc_list, arc)
        else
            #   #-
            #   *-
            @assert haskey(arc_list, ((c_row, c_column-1), :DirR)) ⊻ haskey(arc_list, ((c_row, c_column-1), :DirDR))
            haskey(arc_list, ((c_row, c_column-1), :DirR)) ? areaarc=((c_row, c_column-1), :DirR) : areaarc=((c_row, c_column-1), :DirDR)
            area = arc_list[areaarc].linkArea
            # create new arc
            arc_list[((c_row, c_column), :DirD)] = Arc([], (c_row, c_column), nothing, nothing, area) 
            push!(area_list[area].arm, ((c_row, c_column), :DirD))

            # connect w/ arcs if necessary 
            map((((c_row-1, c_column), :DirD), ((c_row-1, c_column), :DirRD), ((c_row, c_column-1), :DirR), ((c_row-1, c_column), :DirDR))) do arc
                if haskey(arc_list, arc) 

                    area = arc_list[arc].linkArea
                    node_connect((c_row, c_column), arc, area, arc_list, area_list, arc_file, area_file)
                end
            end


        end

    end

    return area_count
end

function rr2v(img, arc_file, area_file)

    nR, nC = size(img) 

    area_count=0
    area_list=Dict{Int, Area}()

    arc_list=Dict{Tuple{Tuple{Int64, Int64}, Symbol}, Arc}()
    # CAN NOT use position alone as key. not unique.
    
    # write first row in area_file
    open(area_file, "w") do f
        print(f, "area, color\n")
    end

    for c_row in 1:(nR-1)
        for c_column in 1:(nC-1)
            area_count = handle_event(img[c_row:(c_row+1), c_column:(c_column+1)], 
                                      c_row, c_column, 
                                      area_count, arc_list, area_list, 
                                      arc_file, area_file)
        end
    end

    # to check/debug they should be empty Dict 
    println("area_list\n", area_list, "\n arc_list \n", arc_list)

end


end




img3 = fill(0, (7,8))
img3[2, 5:7] .= 1
img3[3, [5,7]] .= 1
img3[4, 2:5] .= 1; img3[4, 7] = 1
img3[5, [2,7]] .= 1
img3[6, 2:7] .= 1


R2V.rr2v(img3, "arc.csv", "area.csv")
