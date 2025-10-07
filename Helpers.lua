function Cursor(mx, my)
	local max = 2
	local min = 1
	local color = 15
	PlotLine(mx-max, my, mx-min, my, color)
	PlotLine(mx+min, my, mx+max, my, color)
	PlotLine(mx, my-max, mx, my-min, color)
	PlotLine(mx, my+min, mx, my+max, color)
end
