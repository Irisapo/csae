using Plots


# time  sequence
N = 1000
t_seq = 2 * pi .* [ (i-1)/N for i in 1:N]

a = [ 2 0;  2  1;  2  2;  2  3;  1  3;  1  2;  1  1; 
       0 1; -1  1; -1  2; -1  3; -2  3; -2  2; -2  1;
      -2 0; -2 -1; -2 -2; -2 -3; -1 -3; -1 -2; -1 -1;
      0 -1;  1 -1;  1 -2;  1 -3;  2 -1;  2 -2]
#;2 -3]
#a = [1 -1; 0 2; -1 -1]

# 2 dimention Fourier Transform to draw
inx = a[:, 1]
iny = a[:, 2]
nP = length(inx)

K = nP

x_k = []
y_k = []


# For x
## DFT 
for k in 1:K
	res = sum( inx .* exp.( - (0:nP-1)./nP .* (2*pi) .* (k-1) .* im ) ) 
	push!(x_k, res/nP)
end

## inverse DFT
zx_t = [0 for i in 1:N]
for k in 1:K 
	zx_t += x_k[k] * exp.( t_seq * im * (k-1) )   
end


# For y
for k in 1:K
	res = sum( iny .* exp.( - (0:nP-1)./nP .* (2*pi) .* (k-1) .* im ) ) 
	push!(y_k, res/K)
end

zy_t = [0 for i in 1:N]
for k in 1:K
	zy_t += y_k[k] * exp.( t_seq * im * (k-1) )  
end

plot(a[:, 1], a[:, 2], seriestype = :scatter)  
plot!( real.(zx_t), real.(zy_t), seriestype=:scatter)

	



	
	
