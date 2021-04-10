#Module specialFunctions

using Plots


function fun_nbeta(n::Int64, lb::Float64, ub::Float64)
	# f_n(x) is on [0,1]
	map(x -> n^2*x*(1-x^2)^n, LinRange(lb,ub, 100))
	#=  
		This funtion sequences each has a spike, 
		as n -> inf, the spike -> inf at (x->0) but never on (x=0)
		So it converges to f(x)=0
		{n -> inf, f_n(x) = 0 for x \in (0, 1], and f_n(x=0)=0}.
		For visualization: 
		when n >= 10000,
		equally 100 spaced x \in [0,1] is not able to capture the property of the function f_n(x)
	=#
end



function plot_fun(fun, nry::Array{Int64}, lb::T, ub::T) where {T<:Float64}
	p=plot()
	xs=LinRange(lb, ub, 100)
	map(nry) do n
		ys=fun(n, lb, ub)
		plot!(xs, ys, label=n)
	end		
	display(p)

end


plot_fun(fun=fun_nbeta, [1,2,3,10,100,1000,10000], 0, 1)  # Don't go beyond 10000 for n for the plot

