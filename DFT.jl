using Plots

a = [1 -1; 0 2; -1 -1]

# T sequence
N = 100 
t_seq = [(i-1) * 2 * pi / N for i in 1:100]

plot(a[:, 1], a[:, 2], seriestype = :scatter)  


K = 3
# ^ highest frequency

x_k = []

for k in 1:K
	res = 0
	for i in 1:3
		res += (a[i, 1] + a[i, 2] *im) * exp( - k * 2*pi / 3 * (i-1))
	end
	Base.push!(x_k, res)
end

# Compute end points of epicycloid 
ec = [0 for i in 1:100] 
for k in 1:K
	ec += x_k[k] * exp.( t_seq * im * k )
end
	

plot( real.(ec), imag.(ec) , seriestype = :scatter)

# Apparantely I failed based on this plot... 


