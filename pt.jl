letters_file = "/Users/syyang/Documents/git_syy/csae/letters.jl"
ft_file = "/Users/syyang/Documents/git_syy/csae/lt.jl"

include(letters_file)
include(ft_file)

using Plots

str = "ysy"
cstr = split(str, "")

ls = length(str) 


# Calculate paths 
tN = 500
K=4
l_paths = Dict()
for c in Set(cstr)
	inx = eval(Symbol(c))[:, 1]
	iny = eval(Symbol(c))[:, 2]
	l_paths[c] = draw_path(inx, iny, tN=tN, K=K)
end
	
# Set plot attributes
xlim = (-5, 5 + 10*(ls-1))
ylim = (-5, 5)
color = :darkrainbow

start_x = repeat(r[:, 1], 1, ls) .+ transpose( 10 * (0:(ls-1)) )

# plot can do one->multiple match & multiple->one match 
# This one shows multiple(x)->one(y) match
#pl = plot( start_x[1:2, :], r[1:2, 2],
pl = plot( start_x[[1,1] , :] , [0; 0] .- 10,
	xlim=xlim, ylim=ylim, 
	#marker_z = (2+tN)*ls, 
	#color=color, 
	seriestype=:scatter,
	legend = false,
	size = (1920, 420)
)

anim = Animation()
for i=1:tN
	p_x = [ real(l_paths[c][i]) for c in cstr ] + [ 10*(l-1) for l=1:ls ]
	p_y = [ imag(l_paths[c][i]) for c in cstr ]
	push!(pl, p_x, p_y) 
	frame(anim) 
end

gif(anim, "test2.gif", fps=120) 



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
#
#gif(anim, "test.gif", fps=60)
