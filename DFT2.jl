using Plots

a = [1 -1; 0 2; -1 -1]
a = [ 2 0;  2  1;  2  2;  2  3;  1  3;  1  2;  1  1; 
       0 1; -1  1; -1  2; -1  3; -2  3; -2  2; -2  1;
      -2 0; -2 -1; -2 -2; -2 -3; -1 -3; -1 -2; -1 -1;
      0 -1;  1 -1;  1 -2;  1 -3;  2 -1;  2 -2;  2 -3]

nP = size(a)[1]

K = 3

# T sequence
N = 1000 
t_seq = [(i-1) * 2 * pi / N for i in 1:N]

plot(a[:, 1], a[:, 2], seriestype = :scatter)  

# ^ highest frequency

x_k = [ sum(a[:, 1] + a[:, 2] *im)/nP ]

for k in 1:K
	res = 0
	ser = 0
	for i in 1:nP
		res += (a[i, 1] + a[i, 2] *im) * exp( - k * 2*pi / nP * (i) *im )
		ser += (a[i, 1] + a[i, 2] *im) * exp(  k * 2*pi / nP * (i) *im )
	end
	# normalize x_k
	res /= nP
	ser /= nP
	Base.push!(x_k, res)
	#Base.prepend!(x_k, ser)
	
end

# Compute end points of epicycloid 
ec = [0 for i in 1:N] 
#for k in 1:Int(2*K+1)
for k in 1:(K+1)
	#ec += x_k[k] * exp.( t_seq * im * (k-K-1) )
	ec += x_k[k] * exp.( t_seq * im * (k) )
end
	

plot!( real.(ec), imag.(ec) , seriestype = :scatter)


# The center of the points matters.
# As we need to use this to choose what frequencies should be included in the DFT
