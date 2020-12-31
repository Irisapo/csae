using Images, FileIO
using ImageView
using Statistics
using Random 



function sujoy(img; four_connectivity=true)
	#=
	Function for Edge detection.
	copied from https://juliaimages.org/latest/democards/examples/contours/sujoy_edge_demo/#Edge-detection-using-Sujoy-Filter
	=#

    img_channel = Gray.(img)

    min_val = minimum(img_channel)
    img_channel = img_channel .- min_val
    max_val = maximum(img_channel)

    if max_val == 0
        return img
    end

    img_channel = img_channel./max_val

    if four_connectivity
        krnl_h = centered(Gray{Float32}[0 -1 -1 -1 0; 0 -1 -1 -1 0; 0 0 0 0 0; 0 1 1 1 0; 0 1 1 1 0]./12)
        krnl_v = centered(Gray{Float32}[0 0 0 0 0; -1 -1 0 1 1;-1 -1 0 1 1;-1 -1 0 1 1;0 0 0 0 0 ]./12)
    else
        krnl_h = centered(Gray{Float32}[0 0 -1 0 0; 0 -1 -1 -1 0; 0 0 0 0 0; 0 1 1 1 0; 0 0 1 0 0]./8)
        krnl_v = centered(Gray{Float32}[0 0 0 0 0;  0 -1 0 1 0; -1 -1 0 1 1;0 -1 0 1 0; 0 0 0 0 0 ]./8)
    end

    grad_h = imfilter(img_channel, krnl_h')
    grad_v = imfilter(img_channel, krnl_v')

    grad = (grad_h.^2) .+ (grad_v.^2)

    return grad
end




function extract_points(png_path; threshold=0.1, theta=0.99, seed=1111)

	y_img = load(png_path) 
	
	# Change to Gray scale and filter
	y_contour = sujoy(y_img)
	y_edge = Int.( y_contour .> threshold )

	# Fine coordinates 
	co_ind = findall( x->x>0, y_edge )
	inx = [x[1] for x in co_ind]
	iny = [x[2] for x in co_ind]

	# Randomly romove points
	Random.seed!(seed)
	select_ind = rand(length(inx)) .> theta
	inx_s = inx[select_ind]
	iny_s = iny[select_ind]

	# Shift center
	inx_s .-= Int(floor(mean(inx_s)))
	iny_s .-= Int(floor(mean(iny_s)))
	#plot(inx_s, iny_s, seriestype=:scatter)
	#plot!(iny_s, -inx_s, seriestype=:scatter) # rotate 90 degree counterclockwise

	# Reorder the points 
	theta = [ atan(y,x) for (x,y) in zip(inx_s, iny_s) ]
	ind_sort = sortperm(theta)
	inx_s = inx_s[ind_sort]
	iny_s = iny_s[ind_sort]
	
	return inx_s, iny_s, theta	

end
	 

function draw_path(inx, iny; tN=1000, K=10)


	nP = length(inx)	
	@assert nP==length(iny) "Length of inx and lenght of iny should be the same"

	# T sequence
	t_seq = (0:(tN-1)) / tN * 2 * pi

	# DFT
	x_k = [ sum( inx .+ iny .* im ) / nP ]  ## when frequency k is 0
	for k in 1:K
		res = sum( (inx .+ iny .* im) .* exp.( -2*pi * k * im .* (0:nP-1)./nP ) )
		ser = sum( (inx .+ iny .* im) .* exp.( 2*pi * k * im .* (0:nP-1)./nP ) )
		Base.push!(x_k, res/nP)
		Base.prepend!(x_k, ser/nP)
	end

	# inverse DFT
	x_n = [ 0 for i in 1:tN ]
	for k in 1:(2*K+1)
		x_n += x_k[k] .* exp.( t_seq * im * (k-K-1) )
	end	

	return x_n
end
	


#=
png_path = "~/Desktop/y.png"
=#
#res = extract_points(png_path, 0.2)
#inx_s = res[1]
#iny_s = res[2]
#x_n = draw_path(inx_s, iny_s, K=50)
#plot( inx_s, iny_s, seriestype=:scatter)
#plot!( real.(x_n), imag.(x_n), seriestype=:scatter)

# Apparently I failed at finding the shortest path from a graph ...





