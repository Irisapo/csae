function get_values(file::AbstractString, sep=',', re="\n")
	f = open(file, "r")
	l = read(f, String)
	close(f)

	print(l)
	l = strip(l, sep)
	ll = split(l, sep)

	val = map(ll) do x 
		parse(Float64, x)
	end

	return val
end
