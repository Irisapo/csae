#Module specialFunctions

using Plots


function fun_nbeta(n::Int64, lb::Float64, ub::Float64)
	# Range of this f_n(x) is [0,1]
	map(x -> n^2*x*(1-x^2)^n, LinRange(lb,ub, 100))
	#=  When n > 10000
		equally 100 spaced x \in [0,1] is not able to capture the property of the function f_n(x)
		Because n -> inf, f_n(x) = 0 for x \in (0, 1], and f_n(x=0)=0;
		but very close to 0, f_n(x) supar large
	=#
end



function plot_fun(nry::Array{Int64}, lb::T, ub::T) where {T<:Float64}
	p=plot()
	xs=LinRange(lb, ub, 100)
	map(nry) do n
		ys=fun_nbeta(n, lb, ub)
		plot!(xs, ys, label=n)
	end		
	display(p)

end


plot_fun([1,2,3,10,100,1000,10000], 0, 1)  # Don't go beyond 10000 for n for the plot

