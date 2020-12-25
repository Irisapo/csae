using Plots

a = [1 -1; 0 2; -1 -1]
nP = 3

# T sequence
N = 100 
t_seq = [(i-1) * 2 * pi / N for i in 1:100]

plot(a[:, 1], a[:, 2], seriestype = :scatter)  
# The 3 points connected path is used to calculate DFT and draw path using epicycloid.
# 3 points are too few.. but whatever... 

K = 3
# ^ highest frequency

x_k = []

for k in 1:K
	res = 0
	for i in 1:3
		res += (a[i, 1] + a[i, 2] *im) * exp( - k * 2*pi / nP * (i-1) *im )
	end
	Base.push!(x_k, res)
end

# Compute end points of epicycloid 
ec = [0 for i in 1:100] 
for k in 1:K
	ec += x_k[k] * exp.( t_seq * im * k )
end
	
ec /= nP

plot!( real.(ec), imag.(ec) , seriestype = :scatter)


# When highest frequency is set to be 3 (same as #points), the points are on the path
# But when highest frequency is > 3 (i.g. as 5), I get weird shape.. kind of make sense

