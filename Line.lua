
function PlotLine(x0,y0,x1,y1,c)
	local dx = abs(x1-x0)
	local dy =-abs(y1-y0)

	local sx,sy
	if x0<x1 then sx=1 else sx=-1 end
	if y0<y1 then sy=1 else sy=-1 end

	local err=dx+dy -- error value e_xy
	local e2 = err
	
	while(true) do
		pix(x0,y0, c)
		if x0==x1 and y0==y1 then break end

		e2 = 2*err

		if e2>=dy then -- e_xy+e_x > 0
			err=err+dy
			x0 =x0+sx
		end
		
		if e2<=dx then -- e_xy+e_y < 0
			err=err+dx
			y0 =y0+sy
		end
	end
end
