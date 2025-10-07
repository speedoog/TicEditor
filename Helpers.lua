function Cursor(mx, my)
	local max = 2
	local min = 1
	local color = 15
	line(mx-max, my, mx-min, my, color)
	line(mx+min, my, mx+max, my, color)
	line(mx, my-max, mx, my-min, color)
	line(mx, my+min, mx, my+max, color)
end
