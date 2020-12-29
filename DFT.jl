using Plots

a = [1 -1; 0 2; -1 -1]
a = [ 2 0;  2  1;  2  2;  2  3;  1  3;  1  2;  1  1; 
       0 1; -1  1; -1  2; -1  3; -2  3; -2  2; -2  1;
      -2 0; -2 -1; -2 -2; -2 -3; -1 -3; -1 -2; -1 -1;
      0 -1;  1 -1;  1 -2;  1 -3;  2 -1;  2 -2;  2 -3]

nP = size(a)[1]

# T sequence
N = nP 
t_seq = [(i-1) * 2 * pi / N for i in 1:N]

plot(a[:, 1], a[:, 2], seriestype = :scatter)  

K = nP
# ^ highest frequency

x_k = []

for k in 1:K
	res = 0
	for i in 1:nP
		res += (a[i, 1] + a[i, 2] *im) * exp( - k * 2*pi / nP * (i-1) *im )
	end
	Base.push!(x_k, res)
end

# Compute end points of epicycloid 
ec = [0 for i in 1:N] 
for k in 1:K
	ec += x_k[k] * exp.( t_seq * im * k )
end
	
ec /= nP

plot!( real.(ec), imag.(ec) , seriestype = :scatter)


# Why number of points have to be the same as the number of frequencies??
## When I set N > nP
## I get weird shapes
## But when I set N = nP
## I can get all the exact points from the original input 

