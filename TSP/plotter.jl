using PyPlot

function draw(x, y, filename)
	plot(x, y)
	scatter(x, y, alpha=1,s=60,c="orange", edgecolors="face")
	savefig(filename)
end

