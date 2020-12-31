letters_file = "/Users/syyang/Documents/git_syy/csae/letters.jl"
ft_file = "/Users/syyang/Documents/git_syy/csae/lt.jl"

include(letters_file)
include(ft_file)

using Plots

function generate_plot(str="ysy", gif_name="test.gif"; tN=500, K=5, sizep=(630, 210), color=:phase, showaxis=false, fps=60,
	axis=nothing)

	ls = length(str) 
	x_l = 4

	if ls>1
		cstr = split(str, "")

		# Calculate paths 
		l_paths = Dict()
		for c in Set(cstr)
			inx = eval(Symbol(c))[:, 1]
			iny = eval(Symbol(c))[:, 2]
			l_paths[c] = draw_path(inx, iny, tN=tN, K=K)
		end
			
		# Set plot attributes
		xlim = (-x_l, x_l + 2*x_l*(ls-1))
		ylim = (-5, 5)

		start_x = repeat(r[:, 1], 1, ls) .+ transpose( 2*x_l * (0:(ls-1)) )

		# plot can do one->multiple match & multiple->one match 
		# This one shows multiple(x)->one(y) match
		pl = plot( start_x[1:2 , :], r[1:2, 2] .- 10,
			xlim=xlim, ylim=ylim, 
			marker_z = 1:((2+tN)*ls), 
			color=color, 
			showaxis = showaxis, 
			seriestype=:scatter,
			legend = false,
			size = sizep, 
			axis=axis 
		)

		anim = Animation()
		for i=1:tN
			p_x = [ real(l_paths[c][i]) for c in cstr ] + [ 2*x_l*(l-1) for l=1:ls ]
			p_y = [ imag(l_paths[c][i]) for c in cstr ]
			push!(pl, p_x, p_y) 
			frame(anim) 
		end
	elseif ls == 1 
		## For single letter
		#x_n_y = draw_path(y[:, 1], y[:, 2], K=4, tN=tN)
		#x_n_e = draw_path(e[:, 1], e[:, 2], K=4, tN=tN)
		#x_n = x_n_y
		#pl = plot( y[:, 1], y[:, 2],  marker_z = 1:(size(r)[1] + size(x_n)[1]), xlim=(-5, 5), ylim=(-5, 5), 
		#	marker_z = (+),
		#	color=:darkrainbow,
		#	seriestype=:scatter,
		#	legend = false)
		#anim = Animation()
		#
		#for i=1:tN
		#	push!(pl, real(x_n[i]), imag(x_n[i]))
		#	frame(anim)
		#end
	end

	gif(anim, gif_name, fps=fps) 
end


#size = (1920, 420)
